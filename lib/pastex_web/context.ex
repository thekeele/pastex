defmodule PastexWeb.Context do
  @behaviour Plug

  alias Pastex.Identity.User

  def init(opts), do: opts

  def call(conn, _opts) do
    context = build_context(conn)

    Absinthe.Plug.put_options(conn, context: context)
  end

  defp build_context(conn) do
    with ["Bearer " <> token] <- Plug.Conn.get_req_header(conn, "authorization"),
         {:ok, user_id} <- PastexWeb.Auth.verify(token),
         %User{} = user <- Pastex.Identity.get_user(user_id) do
      %{current_user: user}
    else
      _ -> %{}
    end
  end
end
