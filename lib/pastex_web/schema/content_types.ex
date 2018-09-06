defmodule PastexWeb.Schema.ContentTypes do
  use Absinthe.Schema.Notation

  alias PastexWeb.ContentResolver

  @desc "Blobs of Pasted code"
  object :paste do
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

  enum :body_style do
    value :formatted
    value :original
  end
end
