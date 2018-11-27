defmodule TdPerms.IngestCacheTest do
  @moduledoc """
  Unitary tests for ingest cache
  """
  use ExUnit.Case
  alias TdPerms.IngestCache
  doctest TdPerms.IngestCache

  test "put_ingest returns Ok" do
    ingest = ingest_fixture()
    assert IngestCache.put_ingest(ingest) == {:ok, "OK"}
  end

  test "get_parent_id from an ingest" do
    ingest = ingest_fixture()
    IngestCache.put_ingest(ingest)
    assert String.to_integer(IngestCache.get_parent_id(ingest.id))
     == ingest.domain_id
  end

  test "get_name from a ingest" do
    ingest = ingest_fixture()
    IngestCache.put_ingest(ingest)
    assert IngestCache.get_name(ingest.id)
     == ingest.name
  end

  test "get_ingest_version_id from a ingest" do
    ingest = ingest_fixture()
    IngestCache.put_ingest(ingest)
    assert String.to_integer(IngestCache.get_ingest_version_id(ingest.id))
     == ingest.ingest_version_id
  end

  test "delete_ingest deletes the ingest from cache" do
    ingest = ingest_fixture()
    IngestCache.put_ingest(ingest)
    IngestCache.delete_ingest(ingest.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "ingest:#{ingest.id}"])
  end

  defp ingest_fixture do
    %{id: 1, domain_id: 1, name: "test", ingest_version_id: 1}
  end

end
