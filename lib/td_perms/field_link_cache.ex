defmodule TdPerms.FieldLinkCache do
  @moduledoc """
    Shared cache for Link Manager.
  """
  def get_resources(data_field_id) do
    key = create_key(data_field_id)
    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])

    Enum.map(resources, fn resource ->
      %{
        resource_id: String.to_integer(List.first(String.split(resource, ":::"))),
        resource_name: List.last(String.split(resource, ":::"))
      }
    end)
  end

  def put_field_link(%{
        id: data_field_id,
        resource: %{resource_id: resource_id, resource_name: resource_name}
      }) do
    key = create_key(data_field_id)
    resource = "#{resource_id}:::#{resource_name}"
    Redix.command(:redix, ["SADD", key, resource])
  end

  def delete_field_link(data_field_id) do
    key = create_key(data_field_id)
    Redix.command(:redix, ["DEL", key])
  end

  # TODO: delete resource from a data_field
  def delete_resource_from_link(
        data_field_id,
        resource: %{resource_id: resource_id, resource_name: resource_name}
      ) do
    key = create_key(data_field_id)
    resource = "#{resource_id}:::#{resource_name}"
    Redix.command(:redix, ["SREM", key, resource])
  end

  defp create_key(data_field_id) do
    "data_field:#{data_field_id}"
  end
end
