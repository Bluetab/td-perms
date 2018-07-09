defmodule TdPerms.PermissionsTest do
  use ExUnit.Case
  alias TdPerms.Permissions
  alias TdPerms.Taxonomy
  doctest TdPerms.Permissions
  
  test "blah" do
    session_id = "1234"
    domain = domain_fixture()
    acl_entries = acl_entries_fixture()
    now = DateTime.utc_now() |> DateTime.to_unix
    {:ok, _} = Taxonomy.put_domain(domain)
    Permissions.cache_session_permissions!(session_id, now + 100, acl_entries)
    assert Permissions.has_permission?(session_id, :create_business_concept, "domain", 1)

  end

  defp domain_fixture do
    %{id: 1, parent_ids: [2, 3, 4], name: "foo"}
  end

  defp acl_entries_fixture do
    [%{
      resource_type: "domain",
      resource_id: 4,
      principal_type: "user",
      principal_id: 123,
      permissions: ["create_business_concept"]
    }]
  end

end