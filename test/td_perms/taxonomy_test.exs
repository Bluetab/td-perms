defmodule TdPerms.TaxonomyTest do
  use ExUnit.Case
  alias TdPerms.Taxonomy
  doctest TdPerms.Taxonomy

  test "put_domain returns OK" do
    domain = domain_fixture()
    assert Taxonomy.put_domain(domain) == {:ok, "OK"}
  end

  test "get_parent_ids with self returns parent ids including domain_id" do
    domain = domain_fixture()
    Taxonomy.put_domain(domain)
    assert Taxonomy.get_parent_ids(domain.id) == [domain.id|domain.parent_ids]
  end

  test "get_parent_ids without self returns parent ids excluding domain_id" do
    domain = domain_fixture()
    Taxonomy.put_domain(domain)
    assert Taxonomy.get_parent_ids(domain.id, false) == domain.parent_ids
  end

  test "get_name returns name" do
    domain = domain_fixture()
    Taxonomy.put_domain(domain)
    assert Taxonomy.get_name(domain.id) == domain.name
  end

  defp domain_fixture do
    %{id: 1, parent_ids: [2, 3, 4], name: "foo"}
  end
end
