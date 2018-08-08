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
    assert String.to_integer(BusinessConceptCache.get_parent_id(business_concept.id))
     == business_concept.domain_id
  end

  test "get_name from a business_concept" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)
    assert BusinessConceptCache.get_name(business_concept.id)
     == business_concept.name
  end

  test "get_business_concept_version_id from a business_concept" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)
    assert String.to_integer(BusinessConceptCache.get_business_concept_version_id(business_concept.id))
     == business_concept.business_concept_version_id
  end

  test "get_field_values from a business_concept" do
    q_rule_count = 23
    link_count = 32
    BusinessConceptCache.put_field_values(1, q_rule_count: q_rule_count, link_count: link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(1, [:q_rule_count, :link_count])
    assert String.to_integer(values.q_rule_count) == q_rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "increment q_rule_count and link_count" do
    {:ok, q_rule_count} = BusinessConceptCache.increment(12, :q_rule_count)
    {:ok, link_count} = BusinessConceptCache.increment(12, :link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(12, [:q_rule_count, :link_count])
    assert String.to_integer(values.q_rule_count) == q_rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "decrement q_rule_count and link_count" do
    {:ok, q_rule_count} = BusinessConceptCache.decrement(12, :q_rule_count)
    {:ok, link_count} = BusinessConceptCache.decrement(12, :link_count)
    {:ok, values} = BusinessConceptCache.get_field_values(12, [:q_rule_count, :link_count])
    assert String.to_integer(values.q_rule_count) == q_rule_count
    assert String.to_integer(values.link_count) == link_count
  end

  test "delete_business_concept deletes the business concept from cache" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)
    BusinessConceptCache.delete_business_concept(business_concept.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "business_concept:#{business_concept.id}"])
  end

  defp bc_fixture do
    %{id: 1, domain_id: 1, name: "test", business_concept_version_id: 1}
  end

end
