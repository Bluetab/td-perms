defmodule TdPerms.FieldLinkCache do
  @moduledoc """
    Shared cache for Link Manager.
  """
  def get_resources(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)
    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])

    resources
    |> Enum.map(fn r ->
      r_split = String.split(r, ":")
      %{resource_type: List.first(r_split), resource_id: List.last(r_split)}
    end)
    |> Enum.map(
      &Map.merge(&1, %{
        resource_name: get_resource_attr("name", &1.resource_type, &1.resource_id),
        business_concept_version_id:
          get_resource_attr("business_concept_version_id", &1.resource_type, &1.resource_id)
      })
    )
  end

  def put_field_link(
        %{resource_origin: resource_origin, resource_target: resource_target} = resources
      ) do
    # The link between the resources should be created in both directions
    {key_origin, key_target} = build_keys(resources)

    Redix.pipeline(:redix, [
      ["SADD", key_origin, "#{resource_target.resource_type}:#{resource_target.resource_id}"],
      ["SADD", key_target, "#{resource_origin.resource_type}:#{resource_origin.resource_id}"]
    ])
  end

  def delete_link(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)
    Redix.command(:redix, ["DEL", key])
  end

  def delete_resource_from_link(
        %{resource_origin: resource_origin, resource_target: resource_target} = resources
      ) do
    {key_origin, key_target} = build_keys(resources)

    Redix.pipeline(:redix, [
      ["SREM", key_origin, "#{resource_target.resource_type}:#{resource_target.resource_id}"],
      ["SREM", key_target, "#{resource_origin.resource_type}:#{resource_origin.resource_id}"]
    ])
  end

  def get_resource_attr(field, resource_type, resource_id) do
    {:ok, attr} = Redix.command(:redix, ["HGET", "#{resource_type}:#{resource_id}", field])
    attr
  end

  defp build_keys(resources) do
    resources
    |> Map.keys()
    |> Enum.reduce({}, fn key, acc ->
      %{resource_id: resource_id, resource_type: resource_type} = Map.fetch!(resources, key)
      Tuple.append(acc, create_key(resource_id, resource_type))
    end)
  end

  defp create_key(resource_id, resource_type) do
    "#{resource_type}:#{resource_id}:links"
  end
end
