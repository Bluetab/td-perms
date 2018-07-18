defmodule TdPerms.FieldLinkCacheTest do
  use ExUnit.Case
  alias TdPerms.FieldLinkCache
  alias TdPerms.BusinessConceptCache
  doctest TdPerms.FieldLinkCache

  test "put_field_link returns Ok" do
    field_link = field_link_fixture()
    FieldLinkCache.delete_field_link(field_link.id)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, 1}
  end

  test "put_field_link returns Ok retrieving name from existing resource" do
    bc_fixture()
    field_link = field_link_fixture_without_name()
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

  test "delete_field_link deletes the link from cache" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)
    FieldLinkCache.delete_field_link(field_link.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "field_link:#{field_link.id}"])
  end

  test "delete_resource_from_link deletes the resoruce from cache" do
    delete_resource_fixture()
    assert {:ok, 1} = FieldLinkCache.delete_resource_from_link(List.last(delete_resource_list()))
  end

  defp bc_fixture do
    BusinessConceptCache.put_business_concept(%{id: 18, domain_id: 1, name: "prueba"})
  end

  defp field_link_fixture do
    %{id: 1, resource: %{resource_id: 18, resource_name: "cuadrado"}}
  end

  defp field_link_fixture_without_name do
    %{id: 1, resource: %{resource_id: 18}}
  end

  defp delete_resource_list do
    [%{id: 1, resource: %{resource_id: 18, resource_name: "cuadrado"}},
    %{id: 1, resource: %{resource_id: 19, resource_name: "cuadrado"}}]
  end

  defp delete_resource_fixture do
    delete_resource_list()
      |> Enum.map(&FieldLinkCache.put_field_link(&1))
  end
end
