defmodule TdPerms.DynamicFormCache do
  @moduledoc """
    Shared cache for Dynamic Forms.
  """
  def get_template_content(template_name) do
    key = create_key(template_name)
    {:ok, content} = Redix.command(:redix, ["HGET", key, "content"])
    Poison.decode!(content)
  end

  def put_template_content(%{
        name: template_name,
        content: content
      }) do
    key = create_key(template_name)

    Redix.command(:redix, [
      "HMSET",
      key,
      "content",
      Poison.encode!(content)
    ])
  end

  def delete_template_content(template_name) do
    key = create_key(template_name)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(name) do
    "template_content:#{name}"
  end
end
