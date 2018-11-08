defmodule TdPerms.UserCache do
  @moduledoc """
  Shared cache for users.
  """

  def get_user(id) do
    key = create_key(id)
    case Redix.command!(:redix, ["EXISTS", key]) do
      0 -> nil
      1 ->
        {:ok, [user_name, full_name, email]} = Redix.command(:redix, ["HMGET", key, "user_name", "full_name", "email"])
        %{user_name: user_name, full_name: full_name, email: email}
    end
  end

  def put_user(%{id: id, user_name: user_name, full_name: full_name, email: email}) do
    key = create_key(id)
    Redix.command(:redix, ["HMSET", key, "user_name", user_name, "full_name", full_name, "email", email])
  end

  def get_user_email(full_name) do
    key = create_email_key(full_name)
    {:ok, email} = Redix.command(:redix, ["GET", key])
    email
  end

  def put_user_email(%{full_name: full_name, email: email}) do
    key = create_email_key(full_name)
    Redix.command(:redix, ["SET", key, email])
  end

  def delete_user(id) do
    key = create_key(id)
    Redix.command(:redix, ["DEL", key])
  end

  def get_all_users do
    cursor = 0
    key = "user:*"
    {next_cursor, list_users} = retrieve_list_from_enumerator(cursor, key)
    loop_over_scan_iterations(key, list_users, next_cursor)
  end

  defp loop_over_scan_iterations(_key, acc_list_users, 0), do: acc_list_users

  defp loop_over_scan_iterations(key, acc_list_users, cursor) do
    {next_cursor, list_users} = retrieve_list_from_enumerator(cursor, key)
    acc_list_users = acc_list_users ++ list_users
    loop_over_scan_iterations(key, acc_list_users, next_cursor)
  end

  defp retrieve_list_from_enumerator(cursor, key) do
    {:ok, [head | tail]} = scan_command(cursor, key)
    list_users = get_users_from_list_keys(tail |> List.flatten())
    {String.to_integer(head), list_users}
  end

  defp get_users_from_list_keys(list_user_keys) do
    list_user_keys |> Enum.map(fn uk ->
      user_id =
        uk
          |> String.split(":")
          |> List.last()
          |> String.to_integer()

      user_id
        |> get_user()
        |> Map.merge(Map.new() |> Map.put(:id, user_id))
    end)
  end

  defp scan_command(cursor, key) do
    Redix.command(:redix, ["SCAN", cursor, "MATCH", key])
  end

  defp create_key(id) do
    "user:#{id}"
  end

  defp create_email_key(id) do
    "user_email:#{id}"
  end
end
