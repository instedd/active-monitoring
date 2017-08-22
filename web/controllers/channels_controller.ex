defmodule ActiveMonitoring.ChannelsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Channel,
    Repo,
    Runtime.VerboiceChannel,
    OAuthToken,
    User
  }

  def index(conn, _) do
    channels = User.channels(conn.assigns[:current_user])
    render(conn, "index.json", channels: channels)
  end
end
