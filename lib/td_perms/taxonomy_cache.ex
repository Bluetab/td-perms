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
    key = "domain:*"
    {:ok, keys} = Redix.command(:redix, ["KEYS", key])
    Enum.map(keys, &get_domain(&1))
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
