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
    assert TaxonomyCache.get_parent_ids(domain.id) == [domain.id | domain.parent_ids]
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

  test "get_all_domains returns all the domains in the system" do
    list_domain_fixture()
    |> Enum.map(&TaxonomyCache.put_domain(&1))

    result_list = TaxonomyCache.get_all_domains()

    list_domain_fixture()
    |> Enum.all?(fn (x) ->
      Enum.any?(result_list, &(&1.name == x.name))
    end)
    |> assert
  end

  defp domain_fixture do
    %{id: 1, parent_ids: [2, 3, 4], name: "foo"}
  end

  defp list_domain_fixture do
    [
      %{id: 1, parent_ids: [2, 3, 4], name: "foo_1"},
      %{id: 2, parent_ids: [2, 3, 4], name: "foo_2"},
      %{id: 3, parent_ids: [2, 3, 4], name: "foo_3"}
    ]
  end
end
