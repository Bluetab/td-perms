defmodule TdPerms.RelationCache do
  @moduledoc """
    Shared cache for Relation resources.
  """
  def get_resources(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)

    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])

    resources
    |> Enum.map(&get_common_attributes(&1))
    |> Enum.map(&get_additional_attributes(&1))
  end

  def put_relation(
        resources,
        relation_types
      ) do
    source_target_keys = build_keys(resources)

    relation_types
    |> Enum.map(&execute_sadd_command(source_target_keys, resources, &1))
  end

  def delete_relation(resources) do
    resources
    |> build_keys()
    |> Tuple.to_list()
    |> Enum.map(&Redix.command(:redix, ["DEL", &1]))
  end

  def delete_resource_from_relation(
        resources,
        relation_types
      ) do
    source_target_keys = build_keys(resources)

    relation_types
    |> Enum.map(&execute_srem_command(source_target_keys, resources, &1))
  end

  defp execute_sadd_command(
         {key_source, key_target},
         %{source: source, target: target},
         relation_type
       ) do

    Redix.pipeline(:redix, [
      ["SADD", key_source, "#{target.target_type}:#{target.target_id}:#{relation_type}"],
      ["SADD", key_target, "#{source.source_type}:#{source.source_id}:#{relation_type}"]
    ])
  end

  defp execute_srem_command(
         {key_source, key_target},
         %{source: source, target: target},
         relation_type
       ) do
    Redix.pipeline(:redix, [
      ["SREM", key_source, "#{target.target_type}:#{target.target_id}:#{relation_type}"],
      [
        "SREM",
        key_target,
        "#{source.source_type}:#{source.source_id}:#{relation_type}"
      ]
    ])
  end

  def get_resource_attr(field, resource_type, resource_id) do
    {:ok, attr} = Redix.command(:redix, ["HGET", "#{resource_type}:#{resource_id}", field])
    attr
  end

  defp get_common_attributes(resource) do
    [resource_type, resource_id, relation_type] = resource |> String.split(":")

    Map.new()
    |> Map.put(:resource_id, resource_id)
    |> Map.put(:resource_type, resource_type)
    |> Map.put(:relation_type, relation_type)
  end

  defp get_additional_attributes(
         %{resource_id: resource_id, resource_type: "business_concept"} = resource
       ) do
    Map.new()
    |> Map.put(:name, get_resource_attr("name", "business_concept", resource_id))
    |> Map.put(
      :business_concept_version_id,
      get_resource_attr("business_concept_version_id", "business_concept", resource_id)
    )
    |> Map.merge(resource)
  end

  defp get_additional_attributes(resource), do: resource

  defp build_keys(%{source: source, target: target}) do
    source_key = build_string_key(source)
    target_key = build_string_key(target)

    {source_key, target_key}
  end

  defp build_string_key(%{source_id: source_id, source_type: source_type}) do
    create_key(source_id, source_type)
  end

  defp build_string_key(%{target_id: target_id, target_type: target_type}) do
    create_key(target_id, target_type)
  end

  defp create_key(resource_id, resource_type) do
    "#{resource_type}:#{resource_id}:relations"
  end
end
