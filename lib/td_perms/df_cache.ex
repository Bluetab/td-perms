defmodule TdPerms.DynamicFormCache do
  @moduledoc """
    Shared cache for Dynamic Forms.
  """
  def get_template_content(template_name) do
    key = create_key(template_name)
    {:ok, content} = Redix.command(:redix, ["HGET", key, "content"])
    
    case content do
      nil -> nil
      content -> Poison.decode!(content)
    end
  end

  def get_template_by_name("df_template:"<>template_name) do
    get_template_by_name(template_name)
  end
  def get_template_by_name(template_name) do
    key = create_key(template_name)
    {:ok, [content, label]} = Redix.command(:redix, ["HMGET", key, "content", "label"])
    case content do
      nil -> nil
      content ->
        %{
          name: template_name,
          label: label,
          content: Poison.decode!(content)
        }
    end
  end

  def list_templates() do
    {:ok, keys} = Redix.command(:redix, ["KEYS", create_key("*")])
    Enum.map(keys, &get_template_by_name(&1))
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
