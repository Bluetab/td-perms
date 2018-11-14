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

  test "get_template_by_name invalid key will return nil" do
    assert MockDynamicFormCache.get_template_by_name("invalid:key") == nil
  end

  test "get_default_template will return the default template" do
    template = df_fixture_default()
    MockDynamicFormCache.put_template(template)
    assert MockDynamicFormCache.get_default_template() == Map.drop(template, [:is_default])
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
    %{id: 0, name: "test", content: [%{"name" => "field", "type" => "string"}], label: "label"}
  end

  defp df_fixture(name) do
    %{id: 0, name: name, content: [%{"name" => "field", "type" => "string"}], label: "label"}
  end

  defp df_fixture_default do
    %{
      id: 0,
      name: "test_default",
      content: [%{"name" => "field", "type" => "string"}],
      label: "label",
      is_default: true
    }
  end
end
