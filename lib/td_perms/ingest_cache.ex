defmodule TdPerms.IngestCache do
  @moduledoc """
    Shared cache for Ingests.
  """
  def get_parent_id(ingest_id) do
    key = create_key(ingest_id)
    {:ok, parent_id} = Redix.command(:redix, ["HGET", key, "parent_id"])
    parent_id
  end

  def get_name(ingest_id) do
    key = create_key(ingest_id)
    {:ok, name} = Redix.command(:redix, ["HGET", key, "name"])
    name
  end

  def get_ingest_version_id(ingest_id) do
    key = create_key(ingest_id)
    {:ok, ingest_version_id} = Redix.command(:redix, ["HGET", key, "ingest_version_id"])
    ingest_version_id
  end

  def put_ingest(%{
        id: ingest_id,
        domain_id: parent_id,
        name: name,
        ingest_version_id: ingest_version_id
      }) do
    key = create_key(ingest_id)

    Redix.command(:redix, [
      "HMSET",
      key,
      "parent_id",
      parent_id,
      "name",
      name,
      "ingest_version_id",
      ingest_version_id
    ])
  end

  def delete_ingest(ingest_id) do
    key = create_key(ingest_id)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(ingest_id) do
    "ingest:#{ingest_id}"
  end
end
