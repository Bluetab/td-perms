defmodule TdPerms.TaxonomyCache do
  @moduledoc """
  Shared cache for taxonomy hierarchy.
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
    root_command = if parent_ids == "", do: "SADD", else: "SREM"
    Redix.command(:redix, ["MULTI"])
    Redix.command(:redix, ["HMSET", key, "parent_ids", parent_ids, "name", name])
    Redix.command(:redix, [root_command, root_domains_key(), domain_id])
    Redix.command(:redix, ["EXEC"])
  end

  defp root_domains_key, do: "domains:root"

  def delete_domain(domain_id) do
    key = create_key(domain_id)
    Redix.command(:redix, ["DEL", key])
  end

  @doc """
  Obtain a map of domain names and the corresponding id.

    ## Examples

      iex> {:ok, _} = TaxonomyCache.put_domain(%{id: 42, parent_ids: [], name: "Some domain"})
      iex> TaxonomyCache.get_domain_name_to_id_map()
      ...> |> Map.get("Some domain")
      42

  """
  @doc since: "2.8.0"
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

  @doc """
  Obtain the set of root domain ids.

    ## Examples

      iex> {:ok, _} = TaxonomyCache.put_domain(%{id: 42, parent_ids: [], name: "D1"})
      iex> {:ok, _} = TaxonomyCache.put_domain(%{id: 43, parent_ids: [], name: "D2"})
      iex> {:ok, _} = TaxonomyCache.put_domain(%{id: 44, parent_ids: [1], name: "D3"})
      iex> {:ok, _} = TaxonomyCache.put_domain(%{id: 45, parent_ids: [], name: "D3"})
      iex> root_domain_ids = TaxonomyCache.get_root_domain_ids() |> MapSet.new()
      iex> [42,43,44,45] |> Enum.map(&(MapSet.member?(root_domain_ids, &1)))
      [true, true, false, true]

  """
  @doc since: "2.8.1"
  def get_root_domain_ids do
    {:ok, domain_ids} = Redix.command(:redix, ["SMEMBERS", root_domains_key()])

    domain_ids
    |> Enum.map(&String.to_integer/1)
  end

  defp get_domain_name(key) do
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  defp create_key(domain_id) do
    "domain:#{domain_id}"
  end
end
