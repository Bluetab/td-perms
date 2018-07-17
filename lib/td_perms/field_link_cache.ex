defmodule TdPerms.FieldLinkCache do
  @moduledoc """
    Shared cache for Business Concepts.
  """
  def get_concepts(data_field_id) do
    key = create_key(data_field_id)
    {:ok, concepts} = Redix.command(:redix, ["SMEMBERS", key])
    Enum.map(concepts, fn(concept) -> %{id: String.to_integer(List.first(String.split(concept, ":::"))), name: List.last(String.split(concept, ":::"))} end)
  end

  def put_field_link(%{id: data_field_id, concept: %{id: id, name: name}}) do
    key = create_key(data_field_id)
    concept = "#{id}:::#{name}"
    Redix.command(:redix, ["SADD", key, concept])
  end

  def delete_field_link(data_field_id) do
    key = create_key(data_field_id)
    Redix.command(:redix, ["DEL", key])
  end

  #TODO: delete concept from a data_field

  defp create_key(data_field_id) do
    "data_field:#{data_field_id}"
  end
end
