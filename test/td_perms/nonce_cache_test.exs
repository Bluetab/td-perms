defmodule TdPerms.NonceCacheTest do
  use ExUnit.Case
  alias TdPerms.NonceCache
  doctest TdPerms.NonceCache

  test "a nonce exists in the cache after creation" do
    nonce = NonceCache.create_nonce
    assert NonceCache.exists?(nonce)
  end

  test "a nonce value can be read once after creation" do
    nonce = NonceCache.create_nonce("Some value")
    assert NonceCache.exists?(nonce)
    assert NonceCache.pop(nonce) == "Some value"
    assert NonceCache.pop(nonce) == nil
  end

end
