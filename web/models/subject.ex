defmodule ActiveMonitoring.Subject do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Call, Campaign, Repo, CallAnswer, Subject}
  import Ecto.Query
  import Timex

  schema "subjects" do
    field :phone_number, :string
    field :registration_identifier, :string

    has_many :calls, Call
    belongs_to :campaign, Campaign

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:phone_number, :registration_identifier, :campaign_id])
    |> validate_required([:registration_identifier])
    |> unique_constraint(:registration_identifier, name: :subjects_campaign_id_registration_identifier_index)
    |> assoc_constraint(:campaign)
  end

  def stats(campaign_id) do
    campaign = Repo.get(Campaign, campaign_id)
    cases =
      case campaign.forwarding_condition do
        "all" ->
          calls_with_at_least_one = Repo.all(from c in Call,
            join: ca in CallAnswer, on: ca.call_id == c.id,
            join: s in Subject, on: c.subject_id == s.id,
            where: ca.response == ^true, select: [c.id, s.id])
          chunked = Enum.chunk_by(calls_with_at_least_one, fn([c,_]) -> c end)
          both_yes = Enum.filter(chunked, fn(l) -> Enum.count(l) > 1 end)
          subjects = Enum.map(both_yes, fn([[_,a],_]) -> a end)
          Enum.count(Enum.uniq(subjects))
        _ ->
          Repo.one(from c in Call,
            join: ca in CallAnswer, on: ca.call_id == c.id,
            where: ca.response == ^true, select: count("id"))
      end
    total_subjects = Repo.one(from s in Subject, select: count("id"), where: s.campaign_id == ^campaign_id)
    timeline = Repo.all((from s in Subject, where: s.inserted_at >= ^subtract(now(), Timex.Duration.from_days(90))) |> Call.by_week(:inserted_at))
    %{cases: cases, total_subjects: total_subjects, timeline: timeline}
  end
end
