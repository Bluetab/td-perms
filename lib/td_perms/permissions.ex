defmodule TdPerms.Permissions do
  @permissions Application.get_env(:td_perms, :permissions)
    |> Enum.with_index |> Map.new

  def permissions, do: @permissions |> Map.keys

  def has_permission?(session_id, permission, resource_type, resource_id) when is_bitstring(permission) do
    has_permission?(session_id, String.to_atom(permission), resource_type, resource_id)
  end

  def has_permission?(session_id, permission, resource_type, resource_id) do
    key = get_key(session_id, resource_type, resource_id)
    cmds = Map.get(@permissions, permission)
      |> get_bit_cmd
    {:ok, bits} = Redix.command(:redix, ["BITFIELD"|[key|cmds]])
    bits |> Enum.any?(&(&1 > 0))
  end

  def cache_session_permissions!(session_id, expire_at, acl_entries) do
    pipeline = acl_entries
      |> Enum.flat_map(&(entry_to_commands(session_id, expire_at, &1)))
    Redix.pipeline!(:redix, pipeline)
  end

  defp entry_to_commands(session_id, expire_at, %{resource_type: resource_type, resource_id: resource_id, permissions: perms}) do
    key = get_key(session_id, resource_type, resource_id)
    cmds = perms
      |> Enum.map(& String.to_atom/1)
      |> Enum.map(&(Map.get(@permissions, &1)))
      |> Enum.flat_map(&set_bit_cmd/1)
    [
      ["BITFIELD"|[key|cmds]],
      ["EXPIREAT", key, expire_at]
    ]
  end

  defp get_key(session_id, resource_type, resource_id) do
    ["session", session_id, resource_type, resource_id]
      |> Enum.join(":")
  end

  defp set_bit_cmd(offset), do: ["SET", "u1", offset, 1]

  defp get_bit_cmd(offset), do: ["GET", "u1", offset]

end