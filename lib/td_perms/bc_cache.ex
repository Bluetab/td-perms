defmodule TdPerms.BusinessConceptCache do
  @moduledoc """
    Shared cache for Business Concepts.
  """
  def get_parent_id(business_concept_id) do
    key = create_key(business_concept_id)
    {:ok, parent_id} = Redix.command(:redix, ["HGET", key, "parent_id"])
    parent_id
  end

  def get_name(business_concept_id) do
    key = create_key(business_concept_id)
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  def get_business_concept_version_id(business_concept_id) do
    key = create_key(business_concept_id)
    {:ok, bc_version_id} = Redix.command(:redix, ["HGET", key, "business_concept_version_id"])
    bc_version_id
  end

  def put_business_concept(%{
        id: business_concept_id,
        domain_id: parent_id,
        name: name,
        business_concept_version_id: business_concept_version_id
      }) do
    key = create_key(business_concept_id)

    Redix.command(:redix, [
      "HMSET",
      key,
      "parent_id",
      parent_id,
      "name",
      name,
      "business_concept_version_id",
      business_concept_version_id
    ])
  end

  def delete_business_concept(business_concept_id) do
    key = create_key(business_concept_id)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(business_concept_id) do
    "business_concept:#{business_concept_id}"
  end
end
