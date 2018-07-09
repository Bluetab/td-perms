defmodule TdPerms.TaxonomyCacheTest do
  use ExUnit.Case
  alias TdPerms.TaxonomyCache
  doctest TdPerms.TaxonomyCache

  test "put_domain returns OK" do
    domain = domain_fixture()
    assert TaxonomyCache.put_domain(domain) == {:ok, "OK"}
  end

  test "get_parent_ids with self returns parent ids including domain_id" do
    domain = domain_fixture()
    TaxonomyCache.put_domain(domain)
    assert TaxonomyCache.get_parent_ids(domain.id) == [domain.id|domain.parent_ids]
  end

  test "get_parent_ids without self returns parent ids excluding domain_id" do
    domain = domain_fixture()
    TaxonomyCache.put_domain(domain)
    assert TaxonomyCache.get_parent_ids(domain.id, false) == domain.parent_ids
  end

  test "get_parent_ids when domain has no parents returns an empty list" do
    domain = domain_fixture() |> Map.put(:parent_ids, [])
    TaxonomyCache.put_domain(domain)
    assert TaxonomyCache.get_parent_ids(domain.id, false) == []
  end

  test "get_name returns name" do
    domain = domain_fixture()
    TaxonomyCache.put_domain(domain)
    assert TaxonomyCache.get_name(domain.id) == domain.name
  end

  test "delete_domain deletes the domain from cache" do
    domain = domain_fixture()
    TaxonomyCache.put_domain(domain)
    TaxonomyCache.delete_domain(domain.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "domain:#{domain.id}"])
  end

  defp domain_fixture do
    %{id: 1, parent_ids: [2, 3, 4], name: "foo"}
  end
end
