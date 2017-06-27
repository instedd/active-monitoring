defmodule ActiveMonitoring.Campaign do
  use ActiveMonitoring.Web, :model

  import Ecto.Query, only: [from: 2]

  alias ActiveMonitoring.{Channel, User, Campaign}

  schema "campaigns" do
    field :name, :string
    field :symptoms, {:array, {:array, :string}} # [{id, label}]
    field :forwarding_condition, :string
    field :forwarding_number, :string
    field :audios, {:array, {:array, :string}} # [{(symptom:id|language|welcome|thanks), lang?, audio.uuid}]
    field :langs, {:array, :string}
    field :additional_information, :string
    field :started_at, Ecto.DateTime
    field :ended_at, Ecto.DateTime
    # field :additional_information, :string
    # field :alert_recipients, {:array, :string}
    # field :additional_fields, {:array, :string}

    belongs_to :channel, Channel
    belongs_to :user, User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :symptoms, :forwarding_number, :forwarding_condition, :audios, :langs, :started_at, :ended_at, :channel_id, :user_id, :additional_information])
    |> assoc_constraint(:user)
    |> assoc_constraint(:channel)
  end

  def steps(%{symptoms: symptoms}), do: steps(symptoms)

  def steps(symptoms) when is_list(symptoms) do
    Enum.concat([
      ["language", "welcome"],
      Enum.map(symptoms, fn([id, _]) -> "symptom:#{id}" end),
      ["forward", "educational", "thanks"]
    ])
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

  def active(query) do
    from c in query,
      where: (is_nil(c.ended_at) and not is_nil(c.started_at))
  end

end
