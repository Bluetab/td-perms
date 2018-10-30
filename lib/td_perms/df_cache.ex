defmodule TdPerms.DynamicFormCache do
  @moduledoc """
    Shared cache for Dynamic Forms.
  """
  def get_template_content(template_name) do
    key = create_key(template_name)
    {:ok, content} = Redix.command(:redix, ["HGET", key, "content"])
    Poison.decode!(content)
  end

  def get_template_by_name(template_name) do
    key = create_key(template_name)
    {:ok, [content, label]} = Redix.command(:redix, ["HMGET", key, "content", "label"])
    %{
      name: template_name,
      label: label,
      content: Poison.decode!(content)
    }
  end

  def put_template(%{
        name: template_name,
        content: content,
        label: label
      }) do
    key = create_key(template_name)

    Redix.command(:redix, [
      "HMSET",
      key,
      "content",
      Poison.encode!(content),
      "label",
      label
    ])
  end

  def delete_template(template_name) do
    key = create_key(template_name)
    Redix.command(:redix, ["DEL", key])
  end

  def create_key(name) do
    "df_template:#{name}"
  end
end
