defmodule TdPerms.NonceCache do
  @moduledoc """
  Shared cache for nonces.
  """

  @doc """
  Create a nonce with a specified length and expiry.
  """
  def create_nonce(value \\ "", length \\ 16, expiry_seconds \\ 3600) do
    nonce = generate_random_string(length)
    key = create_key(nonce)
    "OK" = Redix.command!(:redix, ["SETEX", key, expiry_seconds, value])
    nonce
  end

  @doc """
  Returns true if the given nonce exists, false otherwise.
  """
  def exists?(nonce) do
    key = create_key(nonce)

    case Redix.command!(:redix, ["EXISTS", key]) do
      0 -> false
      1 -> true
    end
  end

  @doc """
  Pops a specified nonce.
  """
  def pop(nonce) do
    key = create_key(nonce)
    {:ok, nonce} = Redix.command(:redix, ["GET", key])
    Redix.command(:redix, ["DEL", key])
    nonce
  end

  defp generate_random_string(length) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  defp create_key(nonce) do
    "nonce:#{nonce}"
  end
end
