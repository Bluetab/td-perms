defmodule TdPerms.BusinessConceptCache do
  @moduledoc """
  Shared cache for Business Concepts.
  """

  def exists_bc_in_cache?(business_concept_id) do
    key = existing_bc_set_key()
    {:ok, result} = Redix.command(:redix, ["SISMEMBER", key, business_concept_id])

    case result do
      1 -> true
      _ -> false
    end
  end

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

  def put_business_concept(
        %{
          id: business_concept_id,
          domain_id: parent_id,
          name: name,
          business_concept_version_id: business_concept_version_id
        } = business_concept
      ) do
    current_version = Map.get(business_concept, :current_version)
    key_bc = create_key(business_concept_id)
    key_bc_set = existing_bc_set_key()

    Redix.command(:redix, ["SADD", key_bc_set, business_concept_id])

    Redix.command(:redix, [
      "HMSET",
      key_bc,
      "parent_id",
      parent_id,
      "name",
      name,
      "business_concept_version_id",
      business_concept_version_id,
      "current_version",
      current_version
    ])
  end

  def add_business_concept_to_deprecated_set(business_concept_id) do
    key = deprecated_bc_set_key()
    Redix.command(:redix, ["SADD", key, business_concept_id])
  end

  def get_deprecated_business_concept_set do
    key = deprecated_bc_set_key()
    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])
    resources
  end

  def get_existing_business_concept_set do
    key = existing_bc_set_key()
    {:ok, resources} = Redix.command(:redix, ["SMEMBERS", key])
    resources
  end

  def put_field_values(business_concept_id, values) do
    key = create_key(business_concept_id)

    value_list =
      values
      |> Enum.map(&[elem(&1, 0), elem(&1, 1)])
      |> List.flatten()

    Redix.command(:redix, ["HMSET", key] ++ value_list)
  end

  def get_field_values(_business_concept_id, []), do: %{}

  def get_field_values(business_concept_id, fields) do
    key = create_key(business_concept_id)
    {:ok, values} = Redix.command(:redix, ["HMGET", key] ++ fields)
    {:ok, Map.new(List.zip([fields, values]))}
  end

  def increment(business_concept_id, field) do
    key = create_key(business_concept_id)
    Redix.command(:redix, ["HINCRBY", key, field, 1])
  end

  def decrement(business_concept_id, field) do
    key = create_key(business_concept_id)
    Redix.command(:redix, ["HINCRBY", key, field, -1])
  end

  def delete_business_concept(business_concept_id) do
    key_bc = create_key(business_concept_id)
    key_bc_set = existing_bc_set_key()

    {:ok, relations} =
      Redix.command(:redix, ["KEYS", "business_concept:#{business_concept_id}:*"])

    relations
    |> Enum.each(fn rel -> Redix.command(:redix, ["DEL", rel]) end)

    Redix.command(:redix, ["SREM", key_bc_set, business_concept_id])
    Redix.command(:redix, ["DEL", key_bc])
  end

  def put_bc_parent(%{
        id: business_concept_id,
        parent_id: parent_id
      }) do
    value = "#{business_concept_id}:#{parent_id}"
    Redix.command(:redix, ["SADD", "bg:bc_parents", value])
  end

  def get_bc_parents!() do
    {:ok, members} = Redix.command(:redix, ["SMEMBERS", "bg:bc_parents"])

    members
    |> Enum.map(&String.split(&1, ":"))
    |> Enum.map(fn [id, parent_id] -> {id, parent_id} end)
  end

  def create_key(business_concept_id) do
    "business_concept:#{business_concept_id}"
  end

  def deprecated_bc_set_key do
    "deprecated_business_concepts"
  end

  def existing_bc_set_key do
    "existing_business_concepts"
  end
end
