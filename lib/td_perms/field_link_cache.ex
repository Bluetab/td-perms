defmodule TdPerms.FieldLinkCache do
  @moduledoc """
    Shared cache for Link Manager.
  """
  def get_resources(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)
    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])
    resources
      |> Enum.map(fn (r) ->
        r_split = String.split(r, ":")
        %{resource_type: List.first(r_split), resource_id: List.last(r_split)}
        end)
      |> Enum.map(&Map.put_new(&1, :resource_name, get_resource_attr("name", &1.resource_type, &1.resource_id)))
  end

  def put_field_link(%{
        id: id,
        resource_type: resource_type,
        resource: resource
      }) do
    key = create_key(id, resource_type)
    Redix.command(:redix, ["SADD", key, "#{resource.resource_type}:#{resource.resource_id}"])
  end

  def delete_link(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)
    Redix.command(:redix, ["DEL", key])
  end

  def delete_resource_from_link(%{
        id: id,
        resource_type: resource_type,
        resource: resource
      }) do
    key = create_key(id, resource_type)
    Redix.command(:redix, ["SREM", key, "#{resource.resource_type}:#{resource.resource_id}"])
  end

  def get_resource_attr(field, resource_type, resource_id) do
    {:ok, attr} = Redix.command(:redix, ["HGET", "#{resource_type}:#{resource_id}", field])
    attr
  end

  defp create_key(resource_id, resource_type) do
    "#{resource_type}:#{resource_id}:links"
  end
end
