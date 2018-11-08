defmodule TdPerms.NonceCacheTest do
  use ExUnit.Case
  alias TdPerms.NonceCache
  doctest TdPerms.NonceCache

  test "a nonce exists in the cache after creation" do
    nonce = NonceCache.create_nonce
    assert NonceCache.exists?(nonce)
  end

end
