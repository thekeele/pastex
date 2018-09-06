defmodule PastexWeb.ContentResolver do
  # PastexWeb.Resolvers.Content
  # another style, matches folder structure but has little meaning

  alias Pastex.{Content, Repo}

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

  def get_files(paste, _, _) do
    files = paste |> Ecto.assoc(:files) |> Repo.all()

    {:ok, files}
  end

  def list_pastes(_root_value, _, %{context: context}) do
    {:ok, Content.list_pastes(context[:current_user])}
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
