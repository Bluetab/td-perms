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

  def get_template_by_name("df_template:" <> template_name) do
    get_template_by_name(template_name)
  end
  def get_template_by_name(template_name) do
    key = create_key(template_name)
    template_fields = ["id", "content", "label", "scope"]
    {:ok, [id, content, label, scope]} = Redix.command(:redix, ["HMGET", key] ++ template_fields)
    case content do
      nil -> nil
      content ->
        %{
          id: parse_id(id),
          name: template_name,
          label: label,
          content: Poison.decode!(content),
          scope: scope
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

  def list_templates do
    {:ok, keys} = Redix.command(:redix, ["KEYS", create_key("*")])
    Enum.map(keys, &get_template_by_name(&1))
  end

  def list_templates_by_scope(scope) do
    {:ok, keys} = Redix.command(:redix, ["KEYS", create_key("*")])
    keys
      |> Enum.map(&get_template_by_name(&1))
      |> Enum.filter(&(&1.scope == scope))
  end

  def put_template(%{
        name: template_name,
        content: content,
        label: label,
        id: id,
        scope: scope
      }) do
    key = create_key(template_name)

    Redix.command(:redix, [
      "HMSET",
      key,
      "id",
      id,
      "content",
      Poison.encode!(content),
      "label",
      label,
      "scope",
      scope
    ])
  end

  def delete_template("df_template:" <> template_name) do
    delete_template(template_name)
  end
  def delete_template(template_name) do
    key = create_key(template_name)
    Redix.command(:redix, ["DEL", key])
  end

  def clean_cache do
    {:ok, keys} = Redix.command(:redix, ["KEYS", create_key("*")])
    Enum.map(keys, &delete_template(&1))
  end

  def create_key(name) do
    "df_template:#{name}"
  end
end
