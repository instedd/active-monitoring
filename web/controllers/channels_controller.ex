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

  # def list(conn) do
  #   base_url = "https://verboice-stg.instedd.org"
  #   client = Verboice.Client.new(base_url,ActiveMonitoring.OAuthTokenServer.get_token("verboice", base_url, conn.assigns[:current_user].id))
  #   Verboice.Client.get_channels(client)
  # end
end
