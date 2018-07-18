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
        resource: resource
      }) do
    key = create_key(data_field_id)
    # For now we only have business_concept in the link manager
    # but in the future we should retrieve the field resource_type as param
    resource_name = retrieve_resource_name(resource)
    resource_string = "#{resource.resource_id}:::#{resource_name}"
    Redix.command(:redix, ["SADD", key, resource_string])
  end

  def delete_field_link(data_field_id) do
    key = create_key(data_field_id)
    Redix.command(:redix, ["DEL", key])
  end

  def delete_resource_from_link(%{
        id: data_field_id,
        resource: resource
      }) do
    key = create_key(data_field_id)
    resource_name = retrieve_resource_name(resource)
    resource_string = "#{resource.resource_id}:::#{resource_name}"
    Redix.command(:redix, ["SREM", key, resource_string])
  end

  defp create_key(data_field_id) do
    "data_field:#{data_field_id}"
  end

  defp retrieve_resource_name(resource) do
    if Map.has_key?(resource, :resource_name) do
      resource.resource_name
    else
      retrieve_resource_attr(resource.resource_id, "business_concept", "name")
    end
  end

  defp retrieve_resource_attr(resource_id, resource_type, field) do
    {:ok, value} = Redix.command(:redix, ["HGET", "#{resource_type}:#{resource_id}", field])
    value
  end
end
