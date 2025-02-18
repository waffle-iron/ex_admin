defmodule ExAdmin.Form do
  import Phoenix.HTML.Form
  def input_builder({f, a}, field, opts) do
    # a.adapter().input_builder(a, resource, opts)
    struct = f.data.__struct__
    associations = ExAdmin.Schema.associations(struct)
    type =
      case associations[field] do
        nil   -> struct.__schema__(:type, field)
        assoc -> assoc
      end
    build_input({a, f}, field, type, opts)
  end

  defp build_input({_a, f}, field, :string, opts) do
    text_input(f, field, opts)
  end

  defp build_input({_a, f}, field, type, opts) when type in ~w(integer id)a do
    text_input(f, field, [{:type, :number} | opts])
  end

  defp build_input({_a, f}, field, :boolean, _opts) do
    checkbox(f, field)
  end

  defp build_input({a, f}, field, %Ecto.Association.BelongsTo{} = _assoc, opts) do
    {collection, opts} = Keyword.pop(opts, :collection)
    assoc_list = Keyword.get(a[:associations] || [], field, [])
    collection = for item <- collection || assoc_list, do: {item.name, item.id}
    select(f, field, collection, opts)
  end

  defp build_input({_a, f}, field, type, opts) do
    IO.puts "build_input unknow #{inspect type} for #{inspect field}"
    text_input(f, field, opts)
  end

  # defp defn_and_adapter(%{__struct__: module}),
  #   do: defn_and_adapter(module)

  # defp defn_and_adapter(module) when is_atom(module) do
  #   base =
  #     :ex_admin
  #     |> Application.get_env(:module)

  #   Module.concat([base, Admin]).admin_resource(module)
  #   |> apply(:adapter, [])
  # end

  # defp get_all(f, queryable) do
  #   # f.source.repo.all queryable
  #   IO.inspect Map.from_struct(f.source), label: "f.source..."
  #   # IO.inspect(f.impl, label: "f.impl ...")
  #   []
  # end

end
