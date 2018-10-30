defmodule TdPerms.DynamicFormCacheTest do
  use ExUnit.Case
  alias TdPerms.DynamicFormCache
  doctest TdPerms.DynamicFormCache

  test "put_template_content returns Ok" do
    template = df_fixture()
    assert DynamicFormCache.put_template_content(template) == {:ok, "OK"}
  end

  test "get_template_content" do
    template = df_fixture()
    DynamicFormCache.put_template_content(template)
    assert DynamicFormCache.get_template_content(template.name) == template.content
  end

  test "delete_template_content deletes from cache" do
    template = df_fixture()
    DynamicFormCache.put_template_content(template)
    DynamicFormCache.delete_template_content(template.name)
    key = DynamicFormCache.create_key(template.name)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  defp df_fixture do
    %{name: "test", content: [%{"name" => "field", "type" => "string"}]}
  end

end
