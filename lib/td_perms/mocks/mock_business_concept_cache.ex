defmodule TdPerms.MockBusinessConceptCache do
  @moduledoc """
  A mock permissions resolver for simulating Acl and User Redis helpers
  """
  use Agent

  alias TdPerms.BusinessConceptCache

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: :MockBcCache)
  end

  def clean_cache, do: Agent.update(:MockBcCache, fn _ -> %{} end)

  def get_full_cache, do: Agent.get(:MockBcCache, & &1)

  def get_name(business_concept_id) do
    key = BusinessConceptCache.create_key(business_concept_id)

    :MockBcCache
    |> Agent.get(& &1)
    |> Map.get(key)
    |> Map.get("name")
  end

  def get_business_concept_version_id(business_concept_id) do
    key = BusinessConceptCache.create_key(business_concept_id)

    :MockBcCache
    |> Agent.get(& &1)
    |> Map.get(key)
    |> Map.get("business_concept_version_id")
  end

  def get_existing_business_concept_set do
    key = BusinessConceptCache.existing_bc_set_key()

    :MockBcCache
    |> Agent.get(& &1)
    |> Map.get(key)
  end

  def put_business_concept(%{
        id: business_concept_id,
        domain_id: parent_id,
        name: name,
        business_concept_version_id: business_concept_version_id
      }) do
    key_bc = BusinessConceptCache.create_key(business_concept_id)
    key_bc_set = BusinessConceptCache.existing_bc_set_key()

    Agent.update(:MockBcCache, fn mock ->
      old_item = Map.get(mock, key_bc_set, [])
      new_item = [business_concept_id | old_item]
      Map.put(mock, key_bc_set, new_item)
    end)

    Agent.update(:MockBcCache, fn mock ->
      new_item =
        mock
        |> Map.get(key_bc, %{})
        |> Map.put("parent_id", parent_id)
        |> Map.put("name", name)
        |> Map.put("business_concept_version_id", business_concept_version_id)

      Map.put(mock, key_bc, new_item)
    end)
  end

  def put_field_values(business_concept_id, values) do
    key = BusinessConceptCache.create_key(business_concept_id)

    Agent.update(:MockBcCache, fn mock ->
      old_item = Map.get(mock, key, %{})
      Map.put(mock, key, Enum.into(values, old_item))
    end)

    {:ok, nil}
  end

  def get_field_values(_, []), do: %{}

  def get_field_values(business_concept_id, fields) do
    key = BusinessConceptCache.create_key(business_concept_id)

    :MockBcCache
    |> Agent.get(& &1)
    |> Map.get(key, %{})
    |> Map.take(fields)
  end

  def increment(business_concept_id, field) do
    key = BusinessConceptCache.create_key(business_concept_id)

    Agent.update(:MockBcCache, fn mock ->
      old_item = Map.get(mock, key, %{})
      old_value = Map.get(old_item, field, 0)
      new_item = Map.put(old_item, field, old_value + 1)
      Map.put(mock, key, new_item)
    end)
  end

  def decrement(business_concept_id, field) do
    key = BusinessConceptCache.create_key(business_concept_id)

    Agent.update(:MockBcCache, fn mock ->
      old_item = Map.get(mock, key, %{})
      old_value = Map.get(old_item, field, 0)
      new_item = Map.put(old_item, field, old_value - 1)
      Map.put(mock, key, new_item)
    end)
  end

  # TODO: Implement this
  def get_bc_parents!(), do: []
end
