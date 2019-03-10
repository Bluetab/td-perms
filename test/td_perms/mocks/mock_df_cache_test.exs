defmodule TdPerms.MockMockDynamicFormCacheTest do
  use ExUnit.Case
  alias TdPerms.MockDynamicFormCache
  doctest TdPerms.MockDynamicFormCache

  setup_all do
    start_supervised(MockDynamicFormCache)
    :ok
  end

  test "put_template returns Ok" do
    template = df_fixture()
    assert MockDynamicFormCache.put_template(template) == {:ok, "OK"}
  end

  test "get_template_content gets content" do
    template = df_fixture()
    MockDynamicFormCache.put_template(template)
    assert MockDynamicFormCache.get_template_content(template.name) == template.content
  end

  test "get_template_content invalid key will return nil" do
    assert MockDynamicFormCache.get_template_content("invalid:key") == nil
  end

  test "get_template_by_name gets template" do
    template = df_fixture()
    MockDynamicFormCache.put_template(template)
    assert MockDynamicFormCache.get_template_by_name(template.name) == template
  end

  test "list_templates will return a list of objects" do
    template1 = df_fixture("t1")
    template2 = df_fixture("t2")
    template3 = df_fixture("t3")
    MockDynamicFormCache.put_template(template1)
    MockDynamicFormCache.put_template(template2)
    MockDynamicFormCache.put_template(template3)
    assert length(MockDynamicFormCache.list_templates()) >= 3
  end

  test "list_templates_by_scope will only return template from the requested scope" do
    MockDynamicFormCache.clean_cache()
    MockDynamicFormCache.put_template(df_scope_fixture("t1", "s1"))
    MockDynamicFormCache.put_template(df_scope_fixture("t2", "s2"))
    MockDynamicFormCache.put_template(df_scope_fixture("t3", "s1"))
    MockDynamicFormCache.put_template(df_scope_fixture("t4", "s3"))
    assert length(MockDynamicFormCache.list_templates_by_scope("s1")) == 2
  end

  test "delete_template deletes from cache" do
    template = df_fixture()
    MockDynamicFormCache.put_template(template)
    assert {:ok, _} = MockDynamicFormCache.delete_template(template.name)
    assert MockDynamicFormCache.get_template_by_name(template.name) == nil
  end

  test "clean_cache will remove all records" do
    template1 = df_fixture("t1")
    template2 = df_fixture("t2")
    template3 = df_fixture("t3")
    MockDynamicFormCache.put_template(template1)
    MockDynamicFormCache.put_template(template2)
    MockDynamicFormCache.put_template(template3)

    MockDynamicFormCache.clean_cache()
    assert Enum.empty?(MockDynamicFormCache.list_templates())
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
