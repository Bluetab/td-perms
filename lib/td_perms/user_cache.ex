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

  def delete_user(id) do
    key = create_key(id)
    Redix.command(:redix, ["DEL", key])
  end

  defp create_key(id) do
    "user:#{id}"
  end
end
