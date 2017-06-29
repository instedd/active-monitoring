defmodule ActiveMonitoring.Call do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Campaign, Channel, CallLog, CallAnswer, Subject}

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
end
