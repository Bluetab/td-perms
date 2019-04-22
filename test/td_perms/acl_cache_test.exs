defmodule TdPerms.AclCacheTest do
  use ExUnit.Case
  alias TdPerms.AclCache
  doctest TdPerms.AclCache

  test "set_acl_roles returns Ok" do
    resource_id = 1
    resource_type = "test_type"
    roles = ["role1", "role2", "role3"]
    assert AclCache.set_acl_roles(resource_id, resource_type, roles) == {:ok, length(roles)}
  end

  test "get_acl_roles returns same value that was put" do
    resource_id = 1
    resource_type = "test_type"
    roles = MapSet.new(["role1", "role2", "role3"])
    AclCache.set_acl_roles(resource_id, resource_type, roles)
    roles_result = AclCache.get_acl_roles(resource_id, resource_type)
    assert MapSet.new(roles_result) == roles
  end

  test "delete_acl_roles deletes from cache" do
    resource_id = 1
    resource_type = "test_type"
    roles = ["role1", "role2", "role3"]
    AclCache.set_acl_roles(resource_id, resource_type, roles)
    AclCache.delete_acl_roles(resource_id, resource_type)
    key = AclCache.create_acl_roles_key(resource_id, resource_type)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  test "set_acl_role_users accepts an empty list" do
    resource_id = 1
    resource_type = "test_type"
    role = "role1"
    users = []
    assert {:ok, _} = AclCache.set_acl_role_users(resource_id, resource_type, role, users)
  end

  test "set_acl_role_users returns Ok" do
    resource_id = 1
    resource_type = "test_type"
    role = "role1"
    users = ["user1", "user2", "user3"]
    result = AclCache.set_acl_role_users(resource_id, resource_type, role, users)
    assert result == {:ok, length(users)}
  end

  test "get_acl_role_users returns same value that was put" do
    resource_id = 1
    resource_type = "test_type"
    role = "role1"
    users = MapSet.new(["user1", "user2", "user3"])
    AclCache.set_acl_role_users(resource_id, resource_type, role, users)
    users_result = AclCache.get_acl_role_users(resource_id, resource_type, role)
    assert MapSet.new(users_result) == users
  end

  test "delete_acl_role_users deletes from cache" do
    resource_id = 1
    resource_type = "test_type"
    role = "role1"
    users = ["user1", "user2", "user3"]
    AclCache.set_acl_role_users(resource_id, resource_type, role, users)
    AclCache.delete_acl_role_users(resource_id, resource_type, role)
    key = AclCache.create_acl_role_users_key(resource_id, resource_type, role)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  test "delete_acl_role_user deletes from cache" do
    resource_id = 1
    resource_type = "test_type"
    role = "role1"
    users = ["user1", "user2", "user3"]
    AclCache.set_acl_role_users(resource_id, resource_type, role, users)
    AclCache.delete_acl_role_user(resource_id, resource_type, role, "user1")
    key = AclCache.create_acl_role_users_key(resource_id, resource_type, role)
    {:ok, new_users} = Redix.command(:redix, ["SMEMBERS", "#{key}"])
    assert 2 = Enum.count(new_users)
  end
end
