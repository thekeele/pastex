defmodule PastexWeb.ContentResolver do
  # PastexWeb.Resolvers.Content
  # another style, matches folder structure but has little meaning

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias Pastex.Content

  ## Queries

  def get_excited_name(paste, _, _) do
    {:ok, String.upcase(paste.name)}
  end

  def format_body(file, %{style: :formatted}, _) do
    {:ok, Code.format_string!(file.body)}
  end

  def format_body(file, _arguments, _) do
    {:ok, file.body}
  end

  def get_files(paste, _, %{context: %{loader: loader}}) do
    # less verbose version, uses ecto assoc
    # |> Dataloader.load(:content, :files, paste)

    loader
    |> Dataloader.load(:content, {:many, Content.File}, paste_id: paste.id)
    |> on_load(fn load ->
      files = Dataloader.get(load, :content, {:many, Content.File}, paste_id: paste.id)
      {:ok, files}
    end)

    # files = paste |> Ecto.assoc(:files) |> Repo.all()

    # {:ok, files}
  end

  def list_pastes(_root_value, args, %{context: context}) do
    context[:current_user]
    |> Content.query_pastes()
    |> Absinthe.Relay.Connection.from_query(&Pastex.Repo.all/1, args)
  end

  ## Mutations

  def create_paste(_, %{input: paste_data}, %{context: context}) do
    paste_data =
      case context do
        %{current_user: %{id: id}} ->
          Map.put(paste_data, :author_id, id)

        _ ->
          paste_data
      end

    Content.create_paste(paste_data)
  end
end
