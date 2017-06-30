defmodule ActiveMonitoring.Call do
  use ActiveMonitoring.Web, :model
  use Timex.Ecto.Timestamps

  alias ActiveMonitoring.{Campaign, Channel, CallLog, CallAnswer, Subject, Repo, Call}
  import Ecto.Query
  import Timex
  # @timestamps_opts [type: Timex.Ecto.DateTime]

  schema "calls" do
    field :sid, :string
    field :from, :string
    field :current_step, :string
    field :language, :string

    belongs_to :campaign, Campaign
    belongs_to :channel, Channel

    has_many :call_logs, CallLog
    has_many :call_answers, CallAnswer
    belongs_to :subject, Subject

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:sid, :from, :current_step, :language, :campaign_id, :channel_id])
    |> cast_assoc(:subject)
    |> assoc_constraint(:channel)
    |> assoc_constraint(:campaign)
  end

  def stats() do
    today = Repo.one(from c in Call, where: c.inserted_at == ^today(), select: count("sid"))
    successful_overall = Repo.one(from c in Call, select: count("sid"), where: c.current_step in ["educational","thanks","forward"])
    last_week = Repo.one(from c in Call, where: c.inserted_at > ^subtract(now(), Timex.Duration.from_days(7)), select: count("sid"))
    %{today: today, successful_overall: successful_overall, last_week: last_week}
  end
end
