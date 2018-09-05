defmodule PastexWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  alias PastexWeb.ContentResolver

  @desc "Blobs of Pasted code"
  object :paste do
    field :id, non_null(:id)

    field :author, :user do
      resolve fn
        %{author_id: nil}, _, _ -> {:ok, nil}

        paste, _, _resolution ->
          {:ok, Pastex.Identity.get_user(paste.author_id)}
      end
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

  object :content_queries do
    field :pastes, list_of(non_null(:paste)) do
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
