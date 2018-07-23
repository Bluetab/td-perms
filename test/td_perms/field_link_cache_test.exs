defmodule TdPerms.FieldLinkCacheTest do
  use ExUnit.Case
  alias TdPerms.FieldLinkCache
  alias TdPerms.BusinessConceptCache
  doctest TdPerms.FieldLinkCache

  test "put_field_link returns Ok" do
    field_link = field_link_fixture()
    delete_link(field_link)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, [1, 1]}
  end

  test "put_field_link should return an error when trying to insert to resources into a link" do
    field_link = field_link_fixture()
    delete_link(field_link)
    assert FieldLinkCache.put_field_link(field_link) == {:ok, [1, 1]}
    assert FieldLinkCache.put_field_link(field_link) == {:ok, [0, 0]}
  end

  test "get_resources from a field" do
    bc_fixture()
    resource_list_fixture()
    result_list = FieldLinkCache.get_resources(1, "field")
    assert length(result_list) == 2
    Enum.any?(result_list, &(&1.resource_id == "18"))
    Enum.any?(result_list, &(&1.resource_id == "19"))
  end

  test "delete_field_link deletes the link from cache" do
    field_link = field_link_fixture()
    FieldLinkCache.put_field_link(field_link)
    resource_origin = field_link.resource_origin
    FieldLinkCache.delete_link(resource_origin.resource_id, resource_origin.resource_type)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{resource_origin.resource_type}:#{resource_origin.resource_id}:links"])
  end

  test "delete_resource_from_link deletes the resource from cache" do
    resource_list_fixture()
    field_link = List.last(resource_list())
    assert {:ok, [1, 1]} = FieldLinkCache.delete_resource_from_link(field_link)
    resource_origin = field_link.resource_origin
    Redix.command(:redix, ["EXISTS", "#{resource_origin.resource_type}:#{resource_origin.resource_id}:links"])
  end

  defp bc_fixture do
    BusinessConceptCache.put_business_concept(%{id: 18, domain_id: 1, name: "test_18"})
    BusinessConceptCache.put_business_concept(%{id: 19, domain_id: 1, name: "test_19"})
  end

  defp field_link_fixture do
    %{resource_origin: %{resource_id: 1, resource_type: "field"}, resource_target: %{resource_id: 18, resource_type: "business_concept"}}
  end

  defp resource_list do
    [%{resource_origin: %{resource_id: 1, resource_type: "field"}, resource_target: %{resource_id: 18, resource_type: "business_concept"}},
    %{resource_origin: %{resource_id: 1, resource_type: "field"}, resource_target: %{resource_id: 19, resource_type: "business_concept"}}]
  end

  defp resource_list_fixture do
    resource_list()
      |> Enum.map(&FieldLinkCache.put_field_link(&1))
  end

  defp delete_link(link) do
    link
      |> Map.keys()
      |> Enum.map(&Map.fetch!(link, &1))
      |> Enum.map(&FieldLinkCache.delete_link(&1.resource_id, &1.resource_type))
  end
end
