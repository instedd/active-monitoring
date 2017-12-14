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
    limit = Map.get(params, "limit", "50") |> String.to_integer
    page = Map.get(params, "page", "1") |> String.to_integer

    limit = limit_up_to_50(limit)

    subjects = Repo.get!(Campaign, campaign_id)
    |> authorize_campaign(conn)
    |> assoc(:subjects)
    |> limit(^limit)
    |> conditional_page(limit, page)
    |> Repo.all

    count = Repo.one(from s in Subject, where: s.campaign_id == ^campaign_id, select: count(s.id))

    render(conn, "index.json", subjects: subjects, count: count)
  end

  defp limit_up_to_50 limit do
    if limit in 1..50, do: limit, else: 50
  end

  defp conditional_page query, limit, page do
    offset = limit * (page - 1)
    query |> offset(^offset)
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
