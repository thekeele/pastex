defmodule PastexWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import Absinthe.Resolution.Helpers, only: [on_load: 2]

  alias PastexWeb.ContentResolver

  def get_author(%{author_id: nil}, _, _) do
    {:ok, nil}
  end

  def get_author(paste, _args, %{context: %{loader: loader}}) do
    loader
    |> Dataloader.load(:identity, {:one, Pastex.Identity.User}, id: paste.author_id)
    |> on_load(fn loader ->
      author = Dataloader.get(loader, :identity, {:one, Pastex.Identity.User}, id: paste.author_id)
      {:ok, author}
    end)


    # batch({Pastex.Identity, :get_users}, user_id, fn results ->
    #   {:ok, Map.get(results, user_id)}
    # end)
  end

  @desc "Blobs of Pasted code"
  object :paste do
    field :id, non_null(:id)

    field :author, :user do
      complexity 100

      resolve &get_author/3
    end

    field :name, non_null(:string) do
      # default resolver used when one isn't supplied
      resolve fn paste, _, _ ->
        {:ok, Map.get(paste, :name) || "Untitled"}
      end
    end

    field :excited_name, :string do
      resolve &ContentResolver.get_excited_name/3
    end

    field :description, :string

    @desc "A paste can contain multiple files"
    field :files, non_null(list_of(:file)) do
      resolve &ContentResolver.get_files/3
    end
  end

  object :file do
    field :name, :string

    field :body, :string do
      arg :style, :body_style
      resolve &ContentResolver.format_body/3
    end
  end

  connection(node_type: :paste)

  object :content_queries do
    connection field :pastes, node_type: :paste do
        complexity fn args, child_complexity ->
          trunc((1 + args[:first] * 0.1) * child_complexity)
        end

      resolve &ContentResolver.list_pastes/3
    end
  end

  object :content_mutations do
    field :create_paste, :paste do
      arg :input, non_null(:create_paste_input)
      resolve &ContentResolver.create_paste/3
    end
  end

  # input_object does not allow cycles
  input_object :create_paste_input do
    field :name, non_null(:string)
    field :description, :string
    field :files, non_null(list_of(non_null(:file_input)))
  end

  input_object :file_input do
    field :name, :string
    field :body, :string
  end

  enum :body_style do
    value :formatted
    value :original
  end
end
