defmodule ExAdmin.View do
  @moduledoc """
  View related API functions

  TBD
  """

  alias ExAdmin.Schema

  @doc """
  Return the humanized field name the field value.

  Reflect on the field type. Return the association display name or
  the field value for non associations.

  For associations:
  * Use the Schema's `display_name/1` if defined
  * Use the schema's `:name` field if it exists
  * Otherwise, return "No Display Name"
  """
  @spec get_resource_field(Struct.t, atom) :: {String.t, any}
  def get_resource_field(resource, name) do
    schema = resource.__struct__
    type = schema.__schema__(:type, name)
    schema
    |> Schema.associations()
    |> Keyword.get(name)
    |> get_resource_field(type, resource, schema, name)
  end

  defp get_resource_field(nil, _, resource, _, name) do
    {ExAdmin.Utils.titleize(to_string name), Map.get(resource, name)}
  end

  defp get_resource_field(%{field: field, related: related}, _, resource, _, _name) do
    value =
      if association_loaded? Map.get(resource, field) do
        assoc = Map.get(resource, field)
        cond do
          function_exported?(related, :display_name, 1) ->
            apply related, :display_name, [assoc]
          value = Map.get(assoc, :name) ->
            value
          true ->
            "No Display Name"
        end
      else
        "Not Loaded"
      end
    {ExAdmin.Utils.titleize(to_string field), value}
  end

  @doc """
  Helper to return the current `admin_resource` module.

  Extract the `admin_resource` module from the conn.assigns
  """
  @spec admin_resource(Plug.Conn.t) :: atom
  def admin_resource(conn) do
    conn.assigns.ex_admin.admin_resource
  end

  @doc """
  Extract the params_key from the conn
  """
  @spec params_key(Plug.Conn.t) :: String.t
  def params_key(conn) do
    admin_resource(conn).params_key()
  end

  @doc """
  Extract the repo form the conn
  """
  @spec repo(Plug.Conn.t) :: Struct.t
  def repo(conn) do
    conn.assigns.ex_admin.repo
  end

  @doc """
  Check if the value of an association is loaded
  """
  @spec association_loaded?(any) :: boolean
  def association_loaded?(%Ecto.Association.NotLoaded{}), do: false
  def association_loaded?(%{}), do: true
  def association_loaded?(_), do: false
end
