defmodule ActiveMonitoring.CampaignsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Campaign,
    ChangesetView,
    Repo,
    Call,
    Subject
  }

  def index(conn, _) do
    campaigns = Campaign |> Repo.all

    render(conn, "index.json", campaigns: campaigns)
  end

  def show(conn, %{"id" => id}) do
    campaign = Repo.get!(Campaign, id)
    calls = Call.stats()
    subjects = Subject.stats(id)
    render(conn, "show.json", campaign: campaign, calls: calls, subjects: subjects)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    changeset = Campaign.changeset(%Campaign{}, campaign_params)

    case Repo.insert(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end

  def launch(conn, %{"campaigns_id" => id}) do
    campaign = Repo.get!(Campaign, id)
    changeset = Campaign.changeset(campaign, %{})
    changeset = Ecto.Changeset.put_change(changeset, :started_at, Ecto.DateTime.utc())
    calls = Call.stats()
    subjects = Subject.stats(id)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign, calls: calls, subjects: subjects)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = Repo.get!(Campaign, id)
    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end
end
