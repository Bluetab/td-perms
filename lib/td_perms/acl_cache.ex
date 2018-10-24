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
  def set_acl_roles(resource_type, resource_id, roles = %MapSet{}) do
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
    Redix.command(:redix, ["DEL", key])
    Redix.command(:redix, ["SADD", key] ++ users)
  end
  def set_acl_role_users(resource_type, resource_id, role, users = %MapSet{}) do
    set_acl_role_users(resource_type, resource_id, role, MapSet.to_list(users))
  end

  def delete_acl_role_users(resource_type, resource_id, role) do
    key = create_acl_role_users_key(resource_type, resource_id, role)
    Redix.command(:redix, ["DEL", key])
  end
end
