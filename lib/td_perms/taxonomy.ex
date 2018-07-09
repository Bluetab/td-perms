defmodule TdPerms.Taxonomy do
  @moduledoc """
  Shared cache for taxonomy hierarchy.
  """

  def get_parent_ids(domain_id, with_self \\ true)
  def get_parent_ids(domain_id, false) do
    key = create_key(domain_id)
    {:ok, parent_ids} = Redix.command(:redix, ["HGET", key, "parent_ids"])

    parent_ids
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
  def get_parent_ids(domain_id, true) do
    [domain_id|get_parent_ids(domain_id, false)]
  end

  def get_name(domain_id) do
    key = create_key(domain_id)
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  def put_domain(%{id: domain_id, parent_ids: parent_ids, name: name}) do
    key = create_key(domain_id)
    parent_ids = parent_ids |> Enum.join(",")
    Redix.command(:redix, ["HMSET", key, "parent_ids", parent_ids, "name", name])
  end

  defp create_key(domain_id) do
    "domain:#{domain_id}"
  end
end
