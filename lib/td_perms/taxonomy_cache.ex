defmodule TdPerms.TaxonomyCache do
  @moduledoc """
  Shared cache for taxonomy hierarchy.
  """

  @get_root_domain_keys """
    local cursor = 0
    local root_domain_keys = {}
    repeat
      local result = redis.call('SCAN', cursor, 'MATCH', 'domain:*')
      cursor = tonumber(result[1])
      local domain_keys = result[2]
      local parent_ids
      for i, domain_key in ipairs(domain_keys) do
        parent_ids = redis.call('HGET', domain_key, 'parent_ids')
          if parent_ids == "" then
            root_domain_keys[#root_domain_keys + 1] = domain_key
          end
        end
    until cursor == 0
    return root_domain_keys
  """

  def get_parent_ids(domain_id, with_self \\ true)

  def get_parent_ids(domain_id, false) do
    key = create_key(domain_id)
    {:ok, parent_ids} = Redix.command(:redix, ["HGET", key, "parent_ids"])

    case parent_ids do
      nil ->
        []

      "" ->
        []

      ids ->
        ids
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
    end
  end

  def get_parent_ids(domain_id, true) do
    [domain_id | get_parent_ids(domain_id, false)]
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

  @deprecated "use get_domain_name_to_id_map/0 instead"
  def get_all_domains do
    cursor = 0
    key = "domain:*"
    {next_cursor, init_list_domains} = retrieve_list_from_enumerator(cursor, key)
    loop_over_scan_iterations(key, init_list_domains, next_cursor)
  end

  @doc """
  Obtain a map of domain names and the corresponding id.

    ## Examples

      iex> TaxonomyCache.get_domain_name_to_id_map()
      ...> |> Map.get("foo")
      1

  """
  @since "2.8.0"
  def get_domain_name_to_id_map do
    {:ok, keys} = Redix.command(:redix, ["KEYS", "domain:*"])

    names =
      keys
      |> Enum.map(&Redix.command(:redix, ["HGET", &1, "name"]))
      |> Enum.map(fn {:ok, name} -> name end)

    ids = keys |> Enum.map(&id_from_key/1)
    names |> Enum.zip(ids) |> Map.new()
  end

  defp id_from_key("domain:" <> id), do: String.to_integer(id)

  defp loop_over_scan_iterations(_key, acc_list_domains, 0), do: acc_list_domains

  defp loop_over_scan_iterations(key, acc_list_domains, cursor) do
    {next_cursor, list_domains} = retrieve_list_from_enumerator(cursor, key)
    acc_list_domains = acc_list_domains ++ list_domains
    loop_over_scan_iterations(key, acc_list_domains, next_cursor)
  end

  defp retrieve_list_from_enumerator(cursor, key) do
    {:ok, [head | tail]} = scan_command(cursor, key)
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

  def get_root_domain_ids do
    {:ok, domain_keys} = Redix.command(:redix, ["EVAL", @get_root_domain_keys, 0])

    domain_keys
    |> Enum.map(fn domain_key ->
      domain_key
      |> String.split(":")
      |> List.last()
      |> String.to_integer()
    end)
  end

  defp get_domain(key) do
    %{}
    |> Map.put(:name, get_domain_name(key))
    |> Map.put(:domain_id, key |> String.split(":") |> List.last() |> String.to_integer())
  end

  defp get_domain_name(key) do
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  defp create_key(domain_id) do
    "domain:#{domain_id}"
  end
end
