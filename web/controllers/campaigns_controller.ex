defmodule ActiveMonitoring.CampaignsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Campaign,
    ChangesetView,
    Repo
  }

  def index(conn, _) do
    campaigns = Campaign |> Repo.all

    render(conn, "index.json", campaigns: campaigns)
  end

  def show(conn, %{"id" => id}) do
    campaign = Repo.get!(Campaign, id)

    render(conn, "show.json", campaign: campaign)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    changeset = Campaign.changeset(%Campaign{}, campaign_params)

    case Repo.insert(changeset) do
      {ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = Repo.get!(Campaign, id)
    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end
end
