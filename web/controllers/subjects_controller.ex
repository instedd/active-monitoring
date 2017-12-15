defmodule ActiveMonitoring.SubjectsController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{
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
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all

    count = Repo.one(from s in Subject, where: s.campaign_id == ^campaign_id, select: count(s.id))

    render(conn, "index.json", subjects: subjects, count: count)
  end

  defp page_offset page, limit do
    newPage = case Integer.parse(page) do
      :error -> 1
      {page, _} -> page |> max(1)
    end

    offset = limit * (newPage - 1)
  end

  defp limit_up_to_50 limit do
    case Integer.parse(limit) do
      :error -> 50
      {limit, _} -> limit |> min(50) |> max(1)
    end
  end

  def create(conn, %{"subject" => subject_params, "campaigns_id" => campaign_id}) do
    campaign = Repo.get!(Campaign, campaign_id)
    |> authorize_campaign(conn)

    changeset = campaign
    |> build_assoc(:subjects)
    |> Subject.changeset(subject_params)

    case Repo.insert(changeset) do
      {:ok, subject} ->
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
    subject = Repo.get!(Campaign, campaign_id)
    |> authorize_campaign(conn)
    |> assoc(:subjects)
    |> Repo.get!(subject_id)
    changeset = Subject.changeset(subject, subject_params)

    case Repo.update(changeset) do
      {:ok, subject} ->
        render(conn, "show.json", subject: subject)

      {:error, changeset} ->
        render(conn, ChangesetView, "error.json", changeset: changeset)
    end
  end
end
