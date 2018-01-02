defmodule ActiveMonitoring.Call do
  use ActiveMonitoring.Web, :model
  use Timex.Ecto.Timestamps

  alias ActiveMonitoring.{Campaign, CallLog, CallAnswer, Subject, Repo, Call}
  import Ecto.Query
  import Timex

  schema "calls" do
    field :sid, :string
    field :from, :string
    field :current_step, :string
    field :language, :string

    belongs_to :campaign, Campaign

    has_many :call_logs, CallLog
    has_many :call_answers, CallAnswer
    belongs_to :subject, Subject

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:sid, :from, :current_step, :language, :campaign_id, :subject_id])
    |> assoc_constraint(:campaign)
  end

  def stats(campaign) do
    date = now()
    today = Repo.one(from c in Call, where: c.inserted_at >= ^Timex.beginning_of_day(date), where: c.inserted_at <= ^Timex.end_of_day(date), where: c.campaign_id == ^campaign.id, select: count("sid"))
    successful_overall = Repo.one(from c in Call, select: count("sid"), where: c.current_step in ["educational","thanks","forward"], where: c.campaign_id == ^campaign.id)
    last_week = Repo.one(from c in Call, where: c.inserted_at > ^subtract(now(), Timex.Duration.from_days(7)), where: c.campaign_id == ^campaign.id, select: count("sid"))
    timeline_success = Repo.all((from c in Call, where: c.inserted_at >= ^subtract(now(), Timex.Duration.from_days(90)), where: c.current_step in ["educational","thanks","forward"], where: c.campaign_id == ^campaign.id) |> by_week(:inserted_at))
    timeline_failure = Repo.all((from c in Call, where: c.inserted_at >= ^subtract(now(), Timex.Duration.from_days(90)), where: not c.current_step in ["educational","thanks","forward"], where: c.campaign_id == ^campaign.id) |> by_week(:inserted_at))
    timeline = [timeline_success, timeline_failure]
    %{today: today, successful_overall: successful_overall, last_week: last_week, timeline: timeline}
  end

  def by_week(query, date_field) do
    query
    |> group_by([r], (fragment("date_part('week', ?)", (field(r, ^date_field)))))
    |> select([r], %{x: (fragment("date_part('week', ?)", (field(r, ^date_field)))), y: count("*")})
  end

  def assign_subject(call, subject) do
    changeset(call, %{subject_id: subject.id})
    |> Repo.update!
  end

  defp render_one(call) do
    %{
      id: call.id,
      sid: call.sid,
      current_step: call.current_step,
      language: call.language,
      campaign: call.campaign_id,
      subject: call.subject.phone_number
    }
  end
end
