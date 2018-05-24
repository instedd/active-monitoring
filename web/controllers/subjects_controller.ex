defmodule ActiveMonitoring.SubjectsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
    AidaBot,
    Campaign,
    ChangesetView,
    Repo,
    Subject,
  }

  require Logger

  def index(conn, %{"campaigns_id" => campaign_id} = params) do
    limit = Map.get(params, "limit", "50") |> limit_up_to_50
    offset = Map.get(params, "page", "1") |> page_offset(limit)

    subjects = Repo.get!(Campaign, campaign_id)
    |> authorize_campaign(conn)
    |> assoc(:subjects)
    |> preload(:campaign)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all

    count = Repo.one(from s in Subject, where: s.campaign_id == ^campaign_id, select: count(s.id))

    render(conn, "index.json", subjects: subjects, count: count)
  end

  def export_csv(conn, %{"campaigns_id" => campaign_id}) do
    header = ["ID", "Contact Address", "Enroll date", "First Call Date", "Last Call Date", "Last Successful Call", "Active Case"]

    campaign = Repo.get!(Campaign, campaign_id)
    |> authorize_campaign(conn)

    subjects = campaign
    |> assoc(:subjects)
    |> preload(:campaign)
    |> Repo.all

    csv_rows = subjects
    |> Stream.map(fn subject ->
      [
        subject.registration_identifier,
        subject.contact_address,
        subject |> Subject.enroll_date,
        subject |> Subject.first_call_date || "",
        subject |> Subject.last_call_date || "",
        subject |> Subject.last_successful_call_date || "",
        subject |> Subject.active_case
      ]
    end)

    rows = Stream.concat([[header], csv_rows])

    filename = "export_#{campaign.name}_subjects.csv"
    conn |> csv_stream(rows, filename)
  end

  defp page_offset page, limit do
    newPage = case Integer.parse(page) do
      :error -> 1
      {page, _} -> page |> max(1)
    end

    limit * (newPage - 1)
  end

  defp limit_up_to_50 limit do
    case Integer.parse(limit) do
      :error -> 50
      {limit, _} -> limit |> min(50) |> max(1)
    end
  end

  def create(conn, %{"subject" => subject_params, "campaigns_id" => campaign_id}) do
    campaign =
      Repo.get!(Campaign, campaign_id)
      |> authorize_campaign(conn)

    changeset =
      campaign
      |> build_assoc(:subjects)
      |> Subject.changeset(subject_params)

    case Repo.insert(changeset) do
      {:ok, subject} ->
        subject = Repo.preload(subject, :campaign)

        if campaign.mode == "chat" do
          my_campaign = campaign |> Repo.preload([subjects: :campaign])

          my_campaign
          |> AidaBot.manifest(Subject.active_cases_per_day(my_campaign.subjects, DateTime.utc_now), my_campaign.subjects)
          |> AidaBot.update(my_campaign.aida_bot_id)
        end

        conn
        |> put_status(:created)
        |> put_resp_header("location", campaigns_subjects_path(conn, :index, campaign))
        |> render("show.json", subject: subject)
      {:error, changeset} ->
        Logger.warn "Error when creating subject: #{inspect changeset}"
        conn
        |> put_status(:unprocessable_entity)
        |> render(ActiveMonitoring.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => subject_id, "campaigns_id" => campaign_id, "subject" => subject_params}) do
    campaign =
      Repo.get!(Campaign, campaign_id)
      |> authorize_campaign(conn)

    subject =
      campaign
      |> assoc(:subjects)
      |> Repo.get!(subject_id)

    changeset = Subject.changeset(subject, subject_params)

    case Repo.update(changeset) do
      {:ok, subject} ->
        if campaign.mode == "chat" do
          my_campaign = campaign |> Repo.preload(subjects: :campaign)

          my_campaign
          |> AidaBot.manifest(
            Subject.active_cases_per_day(my_campaign.subjects, DateTime.utc_now()),
            my_campaign.subjects
          )
          |> AidaBot.update(my_campaign.aida_bot_id)
        end

        subject = Repo.preload(subject, :campaign)
        render(conn, "show.json", subject: subject)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end
end
