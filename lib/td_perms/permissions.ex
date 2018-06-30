defmodule TdPerms.Permissions do
  @permissions [
    :is_admin,
    :create_acl_entry,
    :update_acl_entry,
    :delete_acl_entry,
    :create_domain,
    :update_domain,
    :delete_domain,
    :view_domain,
    :create_business_concept,
    :update_business_concept,
    :send_business_concept_for_approval,
    :delete_business_concept,
    :publish_business_concept,
    :reject_business_concept,
    :deprecate_business_concept,
    :manage_business_concept_alias,
    :view_draft_business_concepts,
    :view_approval_pending_business_concepts,
    :view_published_business_concepts,
    :view_versioned_business_concepts,
    :view_rejected_business_concepts,
    :view_deprecated_business_concept
  ] |> Enum.with_index |> Map.new

  def permissions, do: @permissions |> Map.keys

  def has_permission(session_id, permission, resource_type, resource_id) do
    key = ["jti", session_id, resource_type, resource_id]
      |> Enum.join(":")
    cmds = Map.get(@permissions, permission)
      |> get_bit_cmd
    Redix.command(:redix, ["BITFIELD"|[key|cmds]])
  end

  def cache_session_permissions(session_id, acl_entries) do
    pipeline = acl_entries
      |> Enum.map(&(entry_to_command(session_id, &1)))
    Redix.pipeline(:redix, pipeline)
  end

  defp entry_to_command(jti, %{resource_type: resource_type, resource_id: resource_id, permissions: perms}) do
    key = ["jti", jti, resource_type, resource_id]
      |> Enum.join(":")
    cmds = perms
      |> Enum.map(&(Map.get(@permissions, &1)))
      |> Enum.flat_map(&set_bit_cmd/1)
    ["BITFIELD"|[key|cmds]]
  end

  defp set_bit_cmd(offset), do: ["SET", "u1", offset, 1]

  defp get_bit_cmd(offset), do: ["GET", "u1", offset]

end