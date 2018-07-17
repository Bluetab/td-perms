defmodule TdPerms.BusinessConceptCache do
  @moduledoc """
    Shared cache for Business Concepts.
  """
  def get_parent_id(business_concept_id) do
    key = create_key_parent(business_concept_id)
    {:ok, parent_id} = Redix.command(:redix, ["HGET", key, "parent_id"])
    parent_id
  end

  def get_name_id(business_concept_id) do
    key = create_key_name(business_concept_id)
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  def put_business_concept(%{id: business_concept_id, domain_id: parent_id, name: name}) do
    key_parent = create_key_parent(business_concept_id)
    Redix.command(:redix, ["HMSET", key_parent, "parent_id", parent_id])
    key_name = create_key_name(business_concept_id)
    Redix.command(:redix, ["HMSET", key_name, "name", name])
  end

  def delete_business_concept(business_concept_id) do
    key = create_key_parent(business_concept_id)
    Redix.command(:redix, ["DEL", key])
  end

  defp create_key_parent(business_concept_id) do
    "business_concept_parent:#{business_concept_id}"
  end
  defp create_key_name(business_concept_id) do
    "business_concept_name:#{business_concept_id}"
  end
end
