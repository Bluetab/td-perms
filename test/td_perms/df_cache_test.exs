defmodule TdPerms.DynamicFormCacheTest do
  use ExUnit.Case
  alias TdPerms.DynamicFormCache
  doctest TdPerms.DynamicFormCache

  test "put_template returns Ok" do
    template = df_fixture()
    assert DynamicFormCache.put_template(template) == {:ok, "OK"}
  end

  test "get_template_content gets content" do
    template = df_fixture()
    DynamicFormCache.put_template(template)
    assert DynamicFormCache.get_template_content(template.name) == template.content
  end

  test "get_template_content invalid key will return nil" do
    assert DynamicFormCache.get_template_content("invalid:key") == nil
  end

  test "get_template_by_name gets template" do
    template = df_fixture()
    DynamicFormCache.put_template(template)
    assert DynamicFormCache.get_template_by_name(template.name) == template
  end

  test "get_template_by_name invalid key will return nil" do
    assert DynamicFormCache.get_template_by_name("invalid:key") == nil
  end

  test "delete_template deletes from cache" do
    template = df_fixture()
    DynamicFormCache.put_template(template)
    DynamicFormCache.delete_template(template.name)
    key = DynamicFormCache.create_key(template.name)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  defp df_fixture do
    %{name: "test", content: [%{"name" => "field", "type" => "string"}], label: "label"}
  end

end
