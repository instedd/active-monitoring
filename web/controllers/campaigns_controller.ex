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
    campaigns = conn
    |> current_user
    |> assoc(:campaigns)
    |> Repo.all

    render(conn, "index.json", campaigns: campaigns)
  end

  def show(conn, %{"id" => id}) do
    campaign = Campaign.load(conn, id)

    if campaign.started_at != nil do
      calls = Call.stats(campaign)
      subjects = Subject.stats(id)
      render(conn, "show.json", campaign: campaign, calls: calls, subjects: subjects)
    else
      render(conn, "show.json", campaign: campaign)
    end
  end

  def create(conn, %{"campaign" => campaign_params}) do
    user = conn.assigns[:current_user]
    changeset = Campaign.changeset(%Campaign{}, campaign_params)
    changeset = Ecto.Changeset.put_change(changeset, :user_id, user.id)

    case Repo.insert(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end

  def launch(conn, %{"campaigns_id" => campaign_id}) do
    campaign = Campaign.load(conn, campaign_id)

    case Campaign.launch(campaign) do
      {:ok, campaign} ->
        calls = Call.stats(campaign)
        subjects = Subject.stats(campaign_id)
        render(conn, "show.json", campaign: campaign, calls: calls, subjects: subjects)

      {:error, errors} ->
        put_status(conn, 403) |> render(ChangesetView, "error.json", errors)
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = Campaign.load(conn, id)

    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end
end
