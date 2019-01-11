defmodule TdPerms.PermissionsTest do
  use ExUnit.Case
  alias TdPerms.BusinessConceptCache
  alias TdPerms.Permissions
  alias TdPerms.TaxonomyCache
  doctest TdPerms.Permissions

  test "blah" do
    session_id = "1234"
    domain = domain_fixture()
    business_concept = bc_fixture()
    acl_entries = acl_entries_fixture()
    now = DateTime.utc_now() |> DateTime.to_unix
    {:ok, _} = TaxonomyCache.put_domain(domain)
    {:ok, _} = BusinessConceptCache.put_business_concept(business_concept)
    Permissions.cache_session_permissions!(session_id, now + 100, acl_entries)
    assert Permissions.has_permission?(session_id, :create_business_concept, "domain", 1)
    assert Permissions.has_permission?(session_id, :create_business_concept, "business_concept", business_concept.id)
    assert Permissions.has_any_permission?(session_id, [:create_business_concept], "domain", 1)
    assert Permissions.has_any_permission?(session_id, [:create_business_concept], "business_concept", business_concept.id)

    assert Permissions.has_permission?(session_id, :create_business_concept)
    refute Permissions.has_permission?(session_id, :manage_quality_rule)
  end

  defp bc_fixture do
    %{id: 1, domain_id: 1, name: "prueba", business_concept_version_id: 2}
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
