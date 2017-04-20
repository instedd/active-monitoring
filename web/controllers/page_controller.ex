defmodule ActiveMonitoring.PageController do
  use ActiveMonitoring.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
