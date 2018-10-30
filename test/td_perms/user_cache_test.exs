defmodule TdPerms.UserCacheTest do
  @moduledoc false
  use ExUnit.Case
  alias TdPerms.UserCache
  doctest TdPerms.UserCache

  @user_list [
    %{id: 101, user_name: "User name 101", full_name: "fool name 101", email: "some.email101@blah.com"},
    %{id: 102, user_name: "User name 102", full_name: "fool name 102", email: "some.email102@blah.com"},
    %{id: 103, user_name: "User name 103", full_name: "fool name 103", email: "some.email103@blah.com"}
  ]

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

  test "get_all_users returns a list with all the existing users" do
    user_list_fixture()
    result_list = UserCache.get_all_users()
    assert @user_list
      |> Enum.all?(fn x -> Enum.any?(result_list, &(&1 == x)) end)
  end

  defp user_fixture do
    %{id: 42, user_name: "User name", full_name: "fool name", email: "some.email@blah.com"}
  end

  defp user_list_fixture do
    delete_users(@user_list)
    @user_list
      |> Enum.map(&UserCache.put_user(&1))
  end

  defp delete_users(user_list) do
    user_list |> Enum.map(&UserCache.delete_user(Map.get(&1, :id)))
  end
end
