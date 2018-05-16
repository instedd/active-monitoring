defmodule ActiveMonitoring.CampaignsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    Campaign,
    ChangesetView,
    Repo,
    Call,
    Subject,
    AidaBot
  }

  def index(conn, _) do
    campaigns =
      conn
      |> current_user
      |> assoc(:campaigns)
      |> Repo.all()

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
        put_status(conn, :unprocessable_entity) |> render(ChangesetView, "error.json", errors)
    end
  end

  def manifest(conn, %{"campaigns_id" => campaign_id} = params) do
    target_day = Map.get(params, "target_day")

    target_date = case Timex.parse target_day, "{YYYY}{0M}{0D}" do
      {:ok, target_date} -> Timex.shift(target_date, seconds: 1)
      _ -> Timex.now
    end

    campaign =
      Campaign.load(conn, campaign_id)
      |> Repo.preload(subjects: :campaign)

    subjects = Subject.active_cases_per_day(campaign.subjects, target_date)

    manifest = campaign |> AidaBot.manifest(subjects, campaign.subjects)

    conn
    |> put_status(:ok)
    |> put_resp_content_type("application/json")
    |> text(
      manifest
      |> ProperCase.to_snake_case
      |> Poison.encode!
    )
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
