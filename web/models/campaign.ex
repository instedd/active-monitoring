defmodule ActiveMonitoring.Campaign do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Channel, User, Campaign, Subject}
  alias ActiveMonitoring.Router.Helpers
  alias Timex.Timezone

  schema "campaigns" do
    field :name, :string
    field :symptoms, {:array, {:array, :string}} # [{id, label}]
    field :forwarding_condition, :string
    field :forwarding_number, :string
    field :audios, {:array, {:array, :string}} # [{(symptom:id|language|welcome|thanks), lang?, audio.uuid}]
    field :langs, {:array, :string}
    field :additional_information, :string
    field :started_at, Ecto.DateTime
    field :channel, :string
    field :timezone, :string
    field :monitor_duration, :integer
    # field :alert_recipients, {:array, :string}
    # field :additional_fields, {:array, :string}

    belongs_to :user, User
    has_many :subjects, Subject

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :symptoms, :forwarding_number, :forwarding_condition, :audios, :langs, :channel, :user_id, :additional_information, :timezone, :monitor_duration])
    |> validate_inclusion(:additional_information, ["zero", "optional", "compulsory"])
    |> validate_inclusion(:forwarding_condition, ["any", "all"])
    |> assoc_constraint(:user)
  end

  def steps(%{symptoms: symptoms, additional_information: additional_information}) do
    Enum.concat([
      ["language",
       "welcome"],
      Enum.map(symptoms, fn([id, _]) -> "symptom:#{id}" end),
      ["forward",
       (if additional_information == "optional", do: "additional_information_intro"),
       (if additional_information in ["optional", "compulsory"], do: "educational"),
       "thanks"]
    ]) |> Enum.reject(&is_nil/1)
  end

  def symptom_id(nil), do: nil
  def symptom_id(step) do
    if String.starts_with?(step, "symptom") do
      [_, id] = String.split(step, ":", parts: 2)
      id
    end
  end

  def should_forward(%Campaign{forwarding_condition: "any"}, call_answers) do
    Enum.any?(call_answers, fn(%{response: response}) -> response end)
  end

  def should_forward(%Campaign{forwarding_condition: "all"}, call_answers) do
    Enum.all?(call_answers, fn(%{response: response}) -> response end)
  end

  def audio_for(%{audios: audios}, topic, language), do: audio_for(audios, topic, language)

  def audio_for(audios, topic, language) when is_list(audios) do
    Enum.find_value(audios, fn([t, l, id]) -> t == topic && l == language && id end)
  end

  def set_up_verboice(campaign) do
    base_url = "https://verboice-stg.instedd.org"
    client = Verboice.Client.new(base_url,ActiveMonitoring.OAuthTokenServer.get_token("verboice", base_url, campaign.user_id))
    Verboice.Client.create_project("Active Monitoring set up", %{
      status_callback_url: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :status_callback, campaign.id),
      user: "",
      password: "",
      external_service: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, campaign.id)}
    )
  end

  def subjects_pending_check_in(%Campaign{timezone: timezone}, subjects, now) do
    subjects |> Enum.filter(fn(s) -> Subject.active_case(s, now) && has_not_checked_in_today(timezone, Subject.last_successful_call_date(s), now) end)
  end

  defp has_not_checked_in_today(_, nil, _), do: true
  defp has_not_checked_in_today(timezone, last_call_date, now) do
    Timex.before?(Timezone.convert(last_call_date, timezone), Timex.beginning_of_day(Timezone.convert(now, timezone)))
  end
end
