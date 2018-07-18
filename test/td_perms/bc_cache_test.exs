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

  test "delete_business_concept deletes the business concept from cache" do
    business_concept = bc_fixture()
    BusinessConceptCache.put_business_concept(business_concept)
    BusinessConceptCache.delete_business_concept(business_concept.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "business_concept:#{business_concept.id}"])
  end

  defp bc_fixture do
    %{id: 1, domain_id: 1, name: "prueba"}
  end
end
