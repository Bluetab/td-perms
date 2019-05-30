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

  def get_members(resource_id, resource_type) do
    key = create_key(resource_id, resource_type)

    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])

    resources
  end

  def get_resources_from_key(key) do
    key
    |> get_common_attributes
    |> get_additional_attributes
  end

  def put_relation(
        resources,
        relation_types
      ) do
    source_target_keys = build_keys(resources)

    case length(relation_types) do
      0 -> [store_resources(source_target_keys, resources)]
      _ ->
        relation_types
        |> Enum.map(&store_resources(source_target_keys, resources, &1))
    end
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

    case length(relation_types) do
      0 -> [delete_resources(source_target_keys, resources)]
      _ ->
        relation_types
        |> Enum.map(&delete_resources(source_target_keys, resources, &1))
    end
  end

  defp get_resource_attr(field, resource_type, resource_id) do
    {:ok, attr} = Redix.command(:redix, ["HGET", "#{resource_type}:#{resource_id}", field])
    attr
  end
  defp get_resource_attr(field, resource_type, resource_id, relation_type) do
    key = create_relation_type_key(resource_type, resource_id, relation_type)
    {:ok, attr} =
      Redix.command(:redix, ["HGET", key, field])

    attr
  end

  def delete_element_from_set(element, set) do
  {:ok, attr} = Redix.command(:redix, ["SREM", set, element])
    attr
  end

  defp store_resources(
         {key_source, key_target},
         %{source: source, target: target, context: context},
         relation_type \\ ""
       ) do
    key_resource_source = create_relation_type_key(source.source_type, source.source_id, relation_type)
    key_resource_target = create_relation_type_key(target.target_type, target.target_id, relation_type)

    {source_context, target_context} = build_context_from_resources(context)

    result_resource_creation =
      Redix.pipeline(:redix, [
        ["HMSET", key_resource_source, "context", source_context],
        ["HMSET", key_resource_target, "context", target_context]
      ])

    result_resource_append =
      Redix.pipeline(:redix, [
        ["SADD", key_source, key_resource_target],
        ["SADD", key_target, key_resource_source]
      ])

    {result_resource_append, result_resource_creation}
  end

  defp build_context_from_resources(context) do
    source_context = context |> Map.get("source", %{}) |> Poison.encode!()
    target_context = context |> Map.get("target", %{}) |> Poison.encode!()

    {source_context, target_context}
  end

  defp delete_resources(
         {key_source, key_target},
         %{source: source, target: target},
         relation_type \\ ""
       ) do
    key_resource_source = create_relation_type_key(source.source_type, source.source_id, relation_type)
    key_resource_target = create_relation_type_key(target.target_type, target.target_id, relation_type)

    result_deletion_from_set =
      Redix.pipeline(:redix, [
        ["SREM", key_source, key_resource_target],
        ["SREM", key_target, key_resource_source]
      ])

    result_resource_deletion =
      [{key_source, key_resource_source}, {key_target, key_resource_target}]
      |> Enum.filter(fn {key_set, _} ->
        case Redix.command(:redix, ["SCARD", key_set]) do
          {:ok, 0} -> true
          _ -> false
        end
      end)
      |> Enum.map(fn {_, key_resource} -> ["DEL", key_resource] end)
      |> delete_resources()

    {result_deletion_from_set, result_resource_deletion}
  end

  defp delete_resources([]), do: {:ok, :empty_set}

  defp delete_resources(resources_to_delete_pipeline) do
    Redix.pipeline(:redix, resources_to_delete_pipeline)
  end

  defp get_common_attributes(resource) do
    ["relation_type", resource_type, resource_id, relation_type] = resource |> String.split(":")

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

  defp get_additional_attributes(
         %{resource_id: resource_id, resource_type: "data_field", relation_type: relation_type} =
           resource
       ) do
    Map.new()
    |> Map.put(
      :context,
      get_resource_attr("context", "data_field", resource_id, relation_type) |> Poison.decode!()
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
    "links:#{resource_type}:#{resource_id}"
  end

  defp create_relation_type_key(resource_type, resource_id, relation_type) do
    "relation_type:#{resource_type}:#{resource_id}:#{relation_type}"
  end
end
