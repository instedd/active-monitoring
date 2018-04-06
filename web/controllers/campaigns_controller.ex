defmodule ActiveMonitoring.CampaignsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Campaign,
    ChangesetView,
    Repo,
    Call,
    Subject,
    Channel
  }

  def index(conn, _) do
    campaigns = conn
    |> current_user
    |> assoc(:campaigns)
    |> Repo.all

    render(conn, "index.json", campaigns: campaigns)
  end

  def show(conn, %{"id" => id}) do
    campaign = load_campaign(conn, id)

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

  def launch(conn, %{"campaigns_id" => id}) do
    campaign = load_campaign(conn, id)

    if Channel.verify_exclusive(campaign.channel) do
      # Campaign.set_up_verboice(campaign)
      calls = Call.stats(campaign)
      subjects = Subject.stats(id)

      changeset = Campaign.changeset(campaign, %{})
      changeset = Ecto.Changeset.put_change(changeset, :started_at, Ecto.DateTime.utc())
      case Repo.update(changeset) do
        {:ok, campaign} ->
          render(conn, "show.json", campaign: campaign, calls: calls, subjects: subjects)

        {:error, changeset} ->
          put_status(conn, 403) |> render(ChangesetView, "error.json", changeset: changeset)
      end
    else
      put_status(conn, 403) |> render(ChangesetView, "error.json", errors: %{channel: "already in use"})
    end
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = load_campaign(conn, id)

    changeset = Campaign.changeset(campaign, campaign_params)

    case Repo.update(changeset) do
      {:ok, campaign} ->
        render(conn, "show.json", campaign: campaign)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end

  defp load_campaign(conn, id) do
    Repo.get!(Campaign, id) |> authorize_campaign(conn)
  end
end
