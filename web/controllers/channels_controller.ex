defmodule ActiveMonitoring.ChannelsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Channel,
    Repo,
    Runtime.VerboiceChannel
  }

  def index(conn, _) do
    render(conn, "index.json", channels: VerboiceChannel.get_channels(conn.assigns[:current_user].id))
  end
end
