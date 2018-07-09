defmodule TdPerms.TaxonomyTest do
  use ExUnit.Case
  alias TdPerms.Taxonomy
  doctest TdPerms.Taxonomy

  test "put_domain returns OK" do
    domain = domain_fixture()
    assert Taxonomy.put_domain(domain) == {:ok, "OK"}
  end

  test "get_parent_ids returns parent ids" do
    domain = domain_fixture()
    Taxonomy.put_domain(domain)
    assert Taxonomy.get_parent_ids(domain.id) == domain.parent_ids
  end

  test "get_name returns name" do
    domain = domain_fixture()
    Taxonomy.put_domain(domain)
    assert Taxonomy.get_name(domain.id) == domain.name
  end

  defp domain_fixture do
    %{id: 1, parent_ids: [1, 2, 3, 4], name: "foo"}
  end
end
