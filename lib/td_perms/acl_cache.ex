defmodule TdPerms.AclCache do
  @moduledoc """
    Shared cache for Access Control List.
  """
  def get_user_roles(resource_type, resource_id) do
    key = create_key(resource_type, resource_id)
    {:ok, user_roles} = Redix.command(:redix, ["HGET", key, "user_roles"])
    Poison.decode!(user_roles)
  end

  def put_user_roles(%{
        resource_type: resource_type,
        resource_id: resource_id,
        user_roles: user_roles
      }) do
    key = create_key(resource_type, resource_id)

    Redix.command(:redix, [
      "HMSET",
      key,
      "user_roles",
      Poison.encode!(user_roles)
    ])
  end

  def delete_user_roles(resource_type, resource_id) do
    key = create_key(resource_type, resource_id)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(resource_type, resource_id) do
    "acl_user_roles:#{resource_type}:#{resource_id}"
  end
end
