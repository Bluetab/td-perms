defmodule TdPerms.AclCache do
  @moduledoc """
    Shared cache for Access Control List.
  """

  def create_acl_roles_key(resource_type, resource_id) do
    "acl_roles:#{resource_type}:#{resource_id}"
  end

  def get_acl_roles(resource_type, resource_id) do
    key = create_acl_roles_key(resource_type, resource_id)
    {:ok, roles} = Redix.command(:redix, ["SMEMBERS", key])
    roles
  end

  def set_acl_roles(resource_type, resource_id, roles) when is_list(roles) do
    key = create_acl_roles_key(resource_type, resource_id)
    Redix.command(:redix, ["DEL", key])
    Redix.command(:redix, ["SADD", key] ++ roles)
  end

  def set_acl_roles(resource_type, resource_id, %MapSet{} = roles) do
    set_acl_roles(resource_type, resource_id, MapSet.to_list(roles))
  end

  def delete_acl_roles(resource_type, resource_id) do
    key = create_acl_roles_key(resource_type, resource_id)
    Redix.command(:redix, ["DEL", key])
  end

  def create_acl_role_users_key(resource_type, resource_id, role) do
    "acl_role_users:#{resource_type}:#{resource_id}:#{role}"
  end

  def get_acl_role_users(resource_type, resource_id, role) do
    key = create_acl_role_users_key(resource_type, resource_id, role)
    {:ok, role_users} = Redix.command(:redix, ["SMEMBERS", key])
    role_users
  end

  def set_acl_role_users(resource_type, resource_id, role, users) when is_list(users) do
    key = create_acl_role_users_key(resource_type, resource_id, role)

    case users do
      [] ->
        Redix.command(:redix, ["DEL", key])

      _ ->
        Redix.command(:redix, ["DEL", key])
        Redix.command(:redix, ["SADD", key] ++ users)
    end
  end

  def set_acl_role_users(resource_type, resource_id, role, %MapSet{} = users) do
    set_acl_role_users(resource_type, resource_id, role, MapSet.to_list(users))
  end

  def delete_acl_role_users(resource_type, resource_id, role) do
    key = create_acl_role_users_key(resource_type, resource_id, role)
    Redix.command(:redix, ["DEL", key])
  end

  def delete_acl_role_user(resource_type, resource_id, role, user) do
    key = create_acl_role_users_key(resource_type, resource_id, role)
    users = get_acl_role_users(resource_type, resource_id, role)

    case Enum.member?(users, to_string(user)) do
      true -> Redix.command(:redix, ["SREM", key, "#{user}"])
      _ -> {:ok}
    end
  end
end
