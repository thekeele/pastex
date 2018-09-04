defmodule PastexWeb.Schema do
  use Absinthe.Schema

  alias PastexWeb.ContentResolver

  import_types __MODULE__.ContentTypes

  query do
    field :health, :string do
      resolve fn _, _, _ -> {:ok, "up"} end
    end

    field :pastes, list_of(non_null(:paste)) do
      resolve &ContentResolver.list_pastes/3
    end
  end
end
