defmodule TdPerms.FieldLinkCacheTest do
  use ExUnit.Case
  alias TdPerms.FieldLinkCache
  doctest TdPerms.FieldLinkCache

  test "put_field_link returns Ok" do
    field_link = field_link_fixture()
    FieldLinkCache.delete_field_link(field_link.id)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, 1}
  end

  test "put_field_link should return an error when trying to insert to resources into a link" do
    field_link = field_link_fixture()
    FieldLinkCache.delete_field_link(field_link.id)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, 1}
    assert FieldLinkCache.put_field_link(field_link) == {:ok, 0}
  end

  test "get_resources from a field" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)

    assert FieldLinkCache.get_resources(field_link.id) == [
             %{
               resource_id: field_link.resource.resource_id,
               resource_name: field_link.resource.resource_name
             }
           ]
  end

  test "delete_field_link deletes the business concept from cache" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)
    FieldLinkCache.delete_field_link(field_link.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "field_link:#{field_link.id}"])
  end

  defp field_link_fixture do
    %{id: 1, resource: %{resource_id: 18, resource_name: "cuadrado"}}
  end
end
