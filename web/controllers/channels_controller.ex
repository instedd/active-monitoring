defmodule ActiveMonitoring.ChannelsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Channel,
    Repo
  }

  def index(conn, _) do
    channels = Channel |> Repo.all

    render(conn, "index.json", channels: channels)
  end
end
