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
    {:ok, [id, content, label]} = Redix.command(:redix, ["HMGET", key, "id", "content", "label"])
    case content do
      nil -> nil
      content ->
        %{
          id: parse_id(id),
          name: template_name,
          label: label,
          content: Poison.decode!(content)
        }
    end
  end

  def get_default_template() do
    {:ok, [id, name, content, label]} = Redix.command(:redix,
      ["HMGET", "df_template_default", "id", "name", "content", "label"])
    case content do
      nil -> nil
      content ->
        %{
          id: parse_id(id),
          name: name,
          label: label,
          content: Poison.decode!(content)
        }
    end
  end

  defp parse_id(nil), do: nil
  defp parse_id(id_str) do
    case Integer.parse(id_str) do
      :error -> nil
      {id, _} -> id
    end
  end

  def list_templates() do
    {:ok, keys} = Redix.command(:redix, ["KEYS", create_key("*")])
    Enum.map(keys, &get_template_by_name(&1))
  end

  def put_template(%{
        name: template_name,
        content: content,
        label: label,
        id: id
      } = template) do
    key = create_key(template_name)

    case Map.get(template, :is_default, false) do
      true -> Redix.command(:redix, [
          "HMSET",
          "df_template_default",
          "id",
          id,
          "name",
          template_name,
          "content",
          Poison.encode!(content),
          "label",
          label
        ])
      _ -> nil
    end

    Redix.command(:redix, [
      "HMSET",
      key,
      "id",
      id,
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
