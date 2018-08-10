defmodule TdPerms.DataFieldCacheTest do
  use ExUnit.Case
  alias TdPerms.DataFieldCache

  test "put_data_field returns Ok" do
    data_field = data_field_fixture()
    assert DataFieldCache.put_data_field(data_field) == {:ok, "OK"}
  end

  test "get_external_id from a data field" do
    data_field = data_field_fixture()
    DataFieldCache.put_data_field(data_field)
    assert DataFieldCache.get_external_id(data_field.system, data_field.group, data_field.structure, data_field.field)
     == data_field.external_id
  end

  test "delete_data_field deletes the data_field from cache" do
    data_field = data_field_fixture()
    DataFieldCache.put_data_field(data_field)
    DataFieldCache.delete_data_field(data_field.system, data_field.group, data_field.structure, data_field.field)
    key = DataFieldCache.create_key(data_field.system, data_field.group, data_field.structure, data_field.field)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", key])
  end

  defp data_field_fixture do
    %{system: "system", group: "group", structure: "structure", field: "field", external_id: "external_id"}
  end

end
