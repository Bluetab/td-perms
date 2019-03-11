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

  test "list_templates will return a list of objects" do
    DynamicFormCache.clean_cache()
    DynamicFormCache.put_template(df_fixture("t1"))
    DynamicFormCache.put_template(df_fixture("t2"))
    DynamicFormCache.put_template(df_fixture("t3"))
    assert length(DynamicFormCache.list_templates()) == 3
  end

  test "list_templates_by_scope will only return template from the requested scope" do
    DynamicFormCache.clean_cache()
    DynamicFormCache.put_template(df_scope_fixture("t1", "s1"))
    DynamicFormCache.put_template(df_scope_fixture("t2", "s2"))
    DynamicFormCache.put_template(df_scope_fixture("t3", "s1"))
    DynamicFormCache.put_template(df_scope_fixture("t4", "s3"))
    assert length(DynamicFormCache.list_templates_by_scope("s1")) == 2
  end

  test "delete_template deletes from cache" do
    template = df_fixture()
    DynamicFormCache.put_template(template)
    assert {:ok, _} = DynamicFormCache.delete_template(template.name)
    key = DynamicFormCache.create_key(template.name)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  test "clean_cache will remove all records" do
    DynamicFormCache.put_template(df_fixture("t1"))
    DynamicFormCache.put_template(df_fixture("t2"))
    DynamicFormCache.put_template(df_fixture("t3"))

    DynamicFormCache.clean_cache()
    assert Enum.empty?(DynamicFormCache.list_templates())
  end

  defp df_fixture do
    %{
      id: 0,
      name: "test",
      content: [%{"name" => "field", "type" => "string"}],
      label: "label",
      scope: "scope"
    }
  end

  defp df_fixture(name) do
    %{
      id: 0,
      name: name,
      content: [%{"name" => "field", "type" => "string"}],
      label: "label",
      scope: "scope"
    }
  end

  defp df_scope_fixture(name, scope) do
    %{
      id: 0,
      name: name,
      content: [%{"name" => "field", "type" => "string"}],
      label: "label",
      scope: scope
    }
  end
end
