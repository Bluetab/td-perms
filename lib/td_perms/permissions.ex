defmodule TdPerms.Permissions do
  @permissions Application.get_env(:td_perms, :permissions)
    |> Enum.with_index |> Map.new

  @permissions_by_offset Application.get_env(:td_perms, :permissions)
    |> Enum.with_index
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Enum.sort
    |> Enum.map(fn {_, b} -> b end)

  def permissions, do: @permissions |> Map.keys

  def perms, do: @permissions

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

  def get_acls_by_resource_type(session_id, resource_type) do
    pattern = get_key_pattern(session_id, resource_type)
    Redix.command!(:redix, ["KEYS", pattern])
      |> Enum.map(&read_acl_entry(&1))
  end

  defp read_acl_entry(key) do
    permissions = Redix.command!(:redix, ["GET", key])
     |> bitstring_to_list
     |> Enum.zip(@permissions_by_offset)
     |> Enum.filter(fn {bit, _} -> bit == 1 end)
     |> Enum.map(fn {_, perm} -> perm end)
    [_, _, resource_type, resource_id] = key |> String.split(":")
    %{resource_type: resource_type, resource_id: String.to_integer(resource_id), permissions: permissions}
  end
  defp bitstring_to_list(<<>>), do: []
  defp bitstring_to_list(<<x::size(1), rest::bitstring>>) do
    [x|bitstring_to_list(rest)]
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

  defp get_key_pattern(session_id, resource_type) do
    ["session", session_id, resource_type, "*"]
      |> Enum.join(":")
  end
  defp get_key(session_id, resource_type, resource_id) do
    ["session", session_id, resource_type, resource_id]
      |> Enum.join(":")
  end

  defp set_bit_cmd(offset), do: ["SET", "u1", offset, 1]

  defp get_bit_cmd(offset), do: ["GET", "u1", offset]

end