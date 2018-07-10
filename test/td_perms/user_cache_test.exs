defmodule TdPerms.UserCacheTest do
  use ExUnit.Case
  alias TdPerms.UserCache
  doctest TdPerms.UserCache

  test "put_user returns OK" do
    user = user_fixture()
    assert UserCache.put_user(user) == {:ok, "OK"}
  end

  test "get_user returns a map with user_name, full_name and email" do
    user = user_fixture()
    UserCache.put_user(user)
    assert UserCache.get_user(user.id) == Map.take(user, [:user_name, :full_name, :email])
  end

  test "get_user returns nil if the user is not cached" do
    assert UserCache.get_user("MISSING") == nil
  end

  test "delete_user deletes the user from cache" do
    user = user_fixture()
    UserCache.put_user(user)
    UserCache.delete_user(user.id)
    assert {:ok, 0} = Redix.command(:redix, ["EXISTS", "user:#{user.id}"])
  end

  defp user_fixture do
    %{id: 42, user_name: "User name", full_name: "fool name", email: "some.email@blah.com"}
  end
end
