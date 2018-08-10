defmodule TdPerms.DataFieldCache do
  @moduledoc """
    Shared cache for Data Fields
  """

  @external_id "external_id"

  def get_external_id(system, group, structure, field) do
    key = create_key(system, group, structure, field)
    {:ok, external_id} = Redix.command(:redix, ["HGET", key, @external_id])
    external_id
  end

  def put_data_field(%{
        system: system,
        group: group,
        structure: structure,
        field: field,
        external_id: external_id
      }) do
    key = create_key(system, group, structure, field)

    Redix.command(:redix, [
      "HMSET",
      key,
      @external_id,
      external_id
    ])
  end

  def delete_data_field(system, group, structure, field) do
    key = create_key(system, group, structure, field)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(system, group, structure, field) do
    "data_field:#{system}:#{group}:#{structure}:#{field}"
  end
end
