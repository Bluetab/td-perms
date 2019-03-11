defmodule TdPerms.MockDynamicFormCache do
  @moduledoc """
  A mock permissions resolver for simulating Acl and User Redis helpers
  """
  use Agent

  @template_fields [:content, :name, :label, :id, :scope]

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: :MockDfCache)
  end

  def clean_cache do
    Agent.update(:MockDfCache, fn _ -> %{} end)
  end

  def get_template_content(template_name) do
    key = create_key(template_name)
    :MockDfCache
    |> Agent.get(& &1)
    |> Map.get(key, %{content: nil})
    |> Map.get(:content)
  end

  def get_template_by_name("df_template:" <> template_name) do
    get_template_by_name(template_name)
  end
  def get_template_by_name(template_name) do
    key = create_key(template_name)
    :MockDfCache
    |> Agent.get(& &1)
    |> Map.get(key)
  end

  def list_templates do
    :MockDfCache
    |> Agent.get(& &1)
    |> Enum.map(fn {_, v} -> v end)
  end

  def list_templates_by_scope(scope) do
    :MockDfCache
    |> Agent.get(& &1)
    |> Enum.filter(fn {_, v} -> v.scope == scope end)
    |> Enum.map(fn {_, v} -> v end)
  end

  def put_template(%{
        name: template_name,
        content: _,
        label: _,
        scope: _,
        id: _
      } = template) do
    key = create_key(template_name)

    Agent.update(:MockDfCache, fn mock ->
      clean_template = Map.take(template, @template_fields)
      new_mock = Map.put(mock, key, clean_template)
      case Map.get(template, :is_default, false) do
        true -> Map.put(new_mock, "df_template_default", clean_template)
        _ -> new_mock
      end
    end)
    {:ok, "OK"}
  end

  def delete_template(template_name) do
    key = create_key(template_name)
    Agent.update(:MockDfCache, & Map.drop(&1, [key]))
    {:ok, "OK"}
  end

  def create_key(name) do
    "df_template:#{name}"
  end
end
