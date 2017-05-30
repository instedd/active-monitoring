defmodule ActiveMonitoring.CampaignsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{Campaign,Repo}

  def index(conn, _) do
    campaigns = Campaign |> Repo.all

    render(conn, "index.json", campaigns: campaigns)
  end
end
