defmodule TdPerms.RelationCacheTest do
  use ExUnit.Case
  alias TdPerms.BusinessConceptCache
  alias TdPerms.RelationCache
  doctest TdPerms.RelationCache

  test "put_relation returns Ok" do
    {resources, relation_types} = relation_fixture()
    delete_relation(resources)

    put_results = RelationCache.put_relation(resources, relation_types)
    assert length(put_results) == length(relation_types)
    assert Enum.all?(put_results, fn result -> result == {:ok, [1, 1]} end)

    delete_relation(resources)
  end

  test "put_relation should not insert a relation when it is already persisted" do
    {resources, relation_types} = relation_fixture()
    delete_relation(resources)

    put_results = RelationCache.put_relation(resources, relation_types)
    assert length(put_results) == length(relation_types)
    assert Enum.all?(put_results, fn result -> result == {:ok, [1, 1]} end)

    put_results = RelationCache.put_relation(resources, relation_types)
    assert length(put_results) == length(relation_types)
    assert Enum.all?(put_results, fn result -> result == {:ok, [0, 0]} end)

    delete_relation(resources)
  end

  test "delete_relation deletes the link from cache" do
    {resources, relation_types} = relation_fixture()
    RelationCache.put_relation(resources, relation_types)

    source = resources.source
    target = resources.target

    RelationCache.delete_relation(resources)

    assert {:ok, 0} =
             Redix.command(:redix, [
               "EXISTS",
               "#{source.source_type}:#{source.source_id}:relations"
             ])

    assert {:ok, 0} =
             Redix.command(:redix, [
               "EXISTS",
               "#{target.target_type}:#{target.target_id}:relations"
             ])

    delete_relation(resources)
  end

  test "delete_resource_from_relation deletes the resource from cache" do
    resource_list_fixture()
    {resources_to_delete, resource_types} = List.last(resource_list())

    assert [{:ok, [1, 1]}] =
             RelationCache.delete_resource_from_relation(resources_to_delete, resource_types)

    source = resources_to_delete.source
    target = resources_to_delete.target

    assert {:ok, 1} =
             Redix.command(:redix, [
               "EXISTS",
               "#{source.source_type}:#{source.source_id}:relations"
             ])

    assert {:ok, 0} =
             Redix.command(:redix, [
               "EXISTS",
               "#{target.target_type}:#{target.target_id}:relations"
             ])

    delete_resources_list()
  end

  test "get_resources from a data_field" do
    bc_fixture()
    resource_list_fixture()
    result_list = RelationCache.get_resources(1, "data_field")

    assert length(result_list) == 1
    assert Enum.any?(result_list, &(&1.resource_id == "18"))
    assert Enum.any?(result_list, &(&1.name == "test_18"))
    assert Enum.any?(result_list, &(&1.business_concept_version_id == "1"))

    delete_resources_list()
  end

  defp bc_fixture do
    BusinessConceptCache.put_business_concept(%{
      id: 18,
      domain_id: 1,
      name: "test_18",
      business_concept_version_id: 1
    })

    BusinessConceptCache.put_business_concept(%{
      id: 19,
      domain_id: 1,
      name: "test_19",
      business_concept_version_id: 1
    })
  end

  defp relation_fixture do
    {
      %{
        source: %{source_id: 18, source_type: "business_concept"},
        target: %{target_id: 1, target_type: "data_field"}
      },
      ["business_concept_to_field", "business_concept_to_field_master"]
    }
  end

  defp resource_list do
    [
      {
        %{
          source: %{source_id: 18, source_type: "business_concept"},
          target: %{target_id: 1, target_type: "data_field"}
        },
        ["business_concept_to_field"]
      },
      {
        %{
          source: %{source_id: 18, source_type: "business_concept"},
          target: %{target_id: 2, target_type: "data_field"}
        },
        ["business_concept_to_field"]
      }
    ]
  end

  defp resource_list_fixture do
    resource_list()
    |> Enum.map(fn {rs, r_ts} -> RelationCache.put_relation(rs, r_ts) end)
  end

  defp delete_resources_list do
    resource_list()
    |> Enum.map(fn {rs, _} -> RelationCache.delete_relation(rs) end)
  end

  defp delete_relation(relation) do
    relation |> RelationCache.delete_relation()
  end
end
