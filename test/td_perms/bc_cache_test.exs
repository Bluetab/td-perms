defmodule TdPerms.BusinessConceptCacheTest do
  use ExUnit.Case
  alias TdPerms.BusinessConceptCache
  doctest TdPerms.BusinessConceptCache

  test "put_business_concept returns Ok" do
    business_concept = bc_fixture()
    assert BusinessConceptCache.put_business_concept(business_concept) == {:ok, "OK"}
  end

  test "get_parent_id from a business concept" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)

    assert String.to_integer(BusinessConceptCache.get_parent_id(business_concept.id)) ==
             business_concept.domain_id
  end

  test "get_name from a business_concept" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)
    assert BusinessConceptCache.get_name(business_concept.id) == business_concept.name
  end

  test "get_business_concept_version_id from a business_concept" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)

    assert String.to_integer(
             BusinessConceptCache.get_business_concept_version_id(business_concept.id)
           ) == business_concept.business_concept_version_id
  end

  test "get_field_values from a business_concept" do
    rule_count = 23
    link_count = 32
    BusinessConceptCache.put_field_values(1, rule_count: rule_count, link_count: link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(1, [:rule_count, :link_count])
    assert String.to_integer(values.rule_count) == rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "increment rule_count and link_count" do
    {:ok, rule_count} = BusinessConceptCache.increment(12, :rule_count)
    {:ok, link_count} = BusinessConceptCache.increment(12, :link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(12, [:rule_count, :link_count])
    assert String.to_integer(values.rule_count) == rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "decrement rule_count and link_count" do
    {:ok, rule_count} = BusinessConceptCache.decrement(12, :rule_count)
    {:ok, link_count} = BusinessConceptCache.decrement(12, :link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(12, [:rule_count, :link_count])
    assert String.to_integer(values.rule_count) == rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "delete_business_concept deletes the business concept from cache" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)

    BusinessConceptCache.delete_business_concept(business_concept.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "business_concept:#{business_concept.id}"])
    business_concept_ids = BusinessConceptCache.get_existing_business_concept_set()
    assert not Enum.any?(business_concept_ids, &(&1 == business_concept.id))
  end

  test "add_business_concept_to_deprecated_set add a business concept id to set of deprecated business concepts" do
    business_concept = bc_fixture()

    assert {:ok, _} =
             BusinessConceptCache.add_business_concept_to_deprecated_set(business_concept.id)
  end

  test "get_deprecated_business_concept_set returns a set of deprecated business_concept_ids" do
    business_concept = bc_fixture()
    BusinessConceptCache.add_business_concept_to_deprecated_set(business_concept.id)

    business_concept_ids = BusinessConceptCache.get_deprecated_business_concept_set()
    assert length(business_concept_ids) > 0
    assert Enum.any?(business_concept_ids, &(&1 == Integer.to_string(business_concept.id)))
  end

  test "get_existing_business_concept_set returns a set of deleted business_concept_ids" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)

    business_concept_ids = BusinessConceptCache.get_existing_business_concept_set()
    assert length(business_concept_ids) > 0
    assert Enum.any?(business_concept_ids, &(&1 == Integer.to_string(business_concept.id)))
  end

  test "exists_bc_in_cache? returns if a business_concept_id exists in cache" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)

    assert BusinessConceptCache.exists_bc_in_cache?(business_concept.id)
    assert not BusinessConceptCache.exists_bc_in_cache?("not existing bc_id")
  end

  defp bc_fixture do
    %{id: 1, domain_id: 1, name: "test", business_concept_version_id: 1}
  end
end
