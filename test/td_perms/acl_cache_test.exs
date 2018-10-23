defmodule TdPerms.AclCacheTest do
  use ExUnit.Case
  alias TdPerms.AclCache
  doctest TdPerms.AclCache

  test "put_user_roles returns Ok" do
    user_roles = user_roles_fixture()
    assert AclCache.put_user_roles(user_roles) == {:ok, "OK"}
  end

  test "get_user_roles" do
    user_roles = user_roles_fixture()
    AclCache.put_user_roles(user_roles)
    user_roles_result = AclCache.get_user_roles(
      user_roles.resource_type, user_roles.resource_id)
    assert user_roles_result == user_roles.user_roles
  end

  test "delete_user_roles deletes from cache" do
    user_roles = user_roles_fixture()
    AclCache.put_user_roles(user_roles)
    AclCache.delete_user_roles(user_roles.resource_type, user_roles.resource_id)
    key = AclCache.create_key(user_roles.resource_type, user_roles.resource_id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "#{key}"])
  end

  defp user_roles_fixture do
    %{
      resource_type: "type",
      resource_id: 1,
      user_roles: [%{
        "role_name" => "role1", "users" => ["user1"]
      }]
    }
  end

end
