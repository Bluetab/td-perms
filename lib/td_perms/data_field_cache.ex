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

  def set_field_to_structure(%{
        field_id: field_id,
        structure_id: structure_id
      }) do
    key = create_field_to_structure_key(field_id)

    Redix.command(:redix, [
      "SET",
      key,
      structure_id
    ])
  end

  def get_structure_from_field(field_id) do
    key = create_field_to_structure_key(field_id)

    {:ok, value} = Redix.command(:redix, [
      "GET",
      key
    ])
    value
  end

  def create_field_to_structure_key(field_id) do
    "dd:field_to_structure:#{field_id}"
  end

  def create_key(system, group, structure, field) do
    "data_field:#{system}:#{group}:#{structure}:#{field}"
  end
end
