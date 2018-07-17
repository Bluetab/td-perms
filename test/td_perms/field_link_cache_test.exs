defmodule TdPerms.FieldLinkCacheTest do
  use ExUnit.Case
  alias TdPerms.FieldLinkCache
  doctest TdPerms.FieldLinkCache

  test "put_field_link returns Ok" do
    field_link = field_link_fixture()
    FieldLinkCache.delete_field_link(field_link.id)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, 1}
  end

  test "get_concepts from a business concept" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)
    assert FieldLinkCache.get_concepts(field_link.id)
     == ["#{field_link.concept.id}:::#{field_link.concept.name}"]
  end

  test "delete_field_link deletes the business concept from cache" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)
    FieldLinkCache.delete_field_link(field_link.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "field_link:#{field_link.id}"])
  end

  defp field_link_fixture do
    %{id: 1, concept: %{id: 18, name: "cuadrado"}}
  end
end
