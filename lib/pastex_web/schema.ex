defmodule PastexWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types PastexWeb.Schema.{ContentTypes, IdentityTypes}

  query do
    field :health, :string do
      resolve fn _, _, _ -> {:ok, "up"} end
    end

    import_fields :content_queries
    import_fields :identity_queries
  end

  mutation do
    import_fields :content_mutations
    import_fields :identity_mutations
  end

  # missing subscription visibility
  subscription do
    field :paste_created, :paste do
      config fn _, _ ->
        {:ok, topic: "*"}
      end

      trigger [:create_paste], topic: fn _paste ->
        "*"
      end
    end
  end

  # def middleware(middleware, _field, object) do
  #   # middleware is called before each resolution
  #   # IO.puts "------------"
  #   # IO.inspect(object.identifier, label: :object)
  #   # IO.inspect(field.identifier, label: :field)
  #   # IO.puts "------------"
  #   if Absinthe.Type.meta(object, :check_auth) do
  #     [PastexWeb.Middleware.Auth |  middleware]
  #   else
  #     middleware
  #   end
  # end

  def middleware(middleware, _field, _) do
    tracing_middleware() ++ [PastexWeb.Middleware.Auth |  middleware]
  end

  defp tracing_middleware() do
    [ApolloTracing.Middleware.Tracing]
  end

  # def middleware(middleware, _field, _object) do
  #   middleware
  # end
end
