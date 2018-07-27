defmodule TdPerms.TaxonomyCache do
  @moduledoc """
  Shared cache for taxonomy hierarchy.
  """

  def get_parent_ids(domain_id, with_self \\ true)
  def get_parent_ids(domain_id, false) do
    key = create_key(domain_id)
    {:ok, parent_ids} = Redix.command(:redix, ["HGET", key, "parent_ids"])
    case parent_ids do
      nil -> []
      "" -> []
      ids -> ids
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
    end
  end
  def get_parent_ids(domain_id, true) do
    [domain_id|get_parent_ids(domain_id, false)]
  end

  def get_name(domain_id) do
    key = create_key(domain_id)
    get_domain_name(key)
  end

  def put_domain(%{id: domain_id, parent_ids: parent_ids, name: name}) do
    key = create_key(domain_id)
    parent_ids = parent_ids |> Enum.join(",")
    Redix.command(:redix, ["HMSET", key, "parent_ids", parent_ids, "name", name])
  end

  def delete_domain(domain_id) do
    key = create_key(domain_id)
    Redix.command(:redix, ["DEL", key])
  end

  def get_all_domains do
    cursor = 0
    key = "domain:*"
    {next_cursor, init_list_domains} = retrieve_list_from_enumerator(cursor, key)
    loop_over_scan_iteracions(key, init_list_domains, next_cursor)
  end

  defp loop_over_scan_iteracions(_key, acc_list_domains, 0), do: acc_list_domains

  defp loop_over_scan_iteracions(key, acc_list_domains, cursor) do
    {next_cursor, list_domains} = retrieve_list_from_enumerator(cursor, key)
    acc_list_domains = acc_list_domains ++ list_domains
    loop_over_scan_iteracions(key, acc_list_domains, next_cursor)
  end

  defp retrieve_list_from_enumerator(cursor, key) do
    {:ok, [head|tail]} = scan_command(cursor, key)
    list_domains = get_domains_from_list_keys(tail |> List.flatten())
    {String.to_integer(head), list_domains}
  end

  defp get_domains_from_list_keys(list_keys) do
    list_keys
     |> Enum.map(&get_domain(&1))
  end

  defp scan_command(cursor, key) do
    Redix.command(:redix, ["SCAN", cursor, "MATCH", key])
  end

  defp get_domain(key) do
    %{}
      |> Map.put(:name, get_domain_name(key))
      |> Map.put(:domain_id, key |> String.split(":") |> List.last())
  end

  defp get_domain_name(key) do
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  defp create_key(domain_id) do
    "domain:#{domain_id}"
  end
end
