defmodule ActiveMonitoring.PageController do
  use ActiveMonitoring.Web, :controller
  import ActiveMonitoring.Router.Helpers

  def index(conn, %{"path" => path}) do
    user = conn.assigns[:current_user]

    case {path, user} do
      {[], nil} ->
        conn |> render("landing.html")
      {path, nil} ->
        conn |> redirect(to: "#{session_path(conn, :new)}?redirect=/#{Enum.join path, "/"}")
      _ ->
        conn |> render("index.html", user: user)
    end
  end
end
