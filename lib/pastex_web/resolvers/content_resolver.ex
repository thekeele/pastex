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

  def list_pastes(_root_value, _, _) do
    {:ok, Content.list_pastes()}
  end

  ## Mutations

  def create_paste(_, %{input: paste_data}, _) do
    IO.inspect(paste_data, label: "paste_data")

    Content.create_paste(paste_data)
  end
end
