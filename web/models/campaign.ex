defmodule ActiveMonitoring.Campaign do
  use ActiveMonitoring.Web, :model

  alias Timex.Timezone

  alias ActiveMonitoring.{AidaBot, Campaign, Channel, Repo, Subject, User}
  alias ActiveMonitoring.Router.Helpers

  require Logger

  schema "campaigns" do
    field :name, :string
    field :symptoms, {:array, {:array, :string}} # [[id, label]]
    field :forwarding_condition, :string
    field :forwarding_address, :string
    field :audios, {:array, {:array, :string}} # [[(symptom:id|language|welcome|thanks), lang?, audio.uuid]]
    field :chat_texts, {:array, {:array, :string}} # [[(symptom:id|language|welcome|thanks), lang?, text]]
    field :langs, {:array, :string}
    field :additional_information, :string
    field :started_at, Ecto.DateTime
    field :channel, :string
    field :timezone, :string
    field :monitor_duration, :integer
    field :last_reminder_time, Ecto.DateTime
    field :mode, :string # call | chat
    field :fb_page_id, :string
    field :fb_verify_token, :string
    field :fb_access_token, :string
    field :aida_bot_id, :string
    # field :alert_recipients, {:array, :string}
    # field :additional_fields, {:array, :string}

    belongs_to :user, User
    has_many :subjects, Subject

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name,
        :symptoms,
        :forwarding_address,
        :forwarding_condition,
        :audios,
        :chat_texts,
        :langs,
        :channel,
        :user_id,
        :additional_information,
        :timezone,
        :monitor_duration,
        :last_reminder_time,
        :mode,
        :fb_page_id,
        :fb_verify_token,
        :fb_access_token,
        :aida_bot_id
      ])
    |> default_mode
    |> validate_inclusion(:additional_information, ["zero", "optional", "compulsory"])
    |> validate_inclusion(:forwarding_condition, ["any", "all"])
    |> validate_mode
    |> assoc_constraint(:user)
  end

  def symptom_steps(%{symptoms: symptoms}) do
    Enum.map(symptoms, fn([id, _]) -> "symptom:#{id}" end)
  end

  def chat_steps(campaign) do
    symptom_steps(campaign)
  end

  def steps(%{additional_information: additional_information} = campaign) do
    Enum.concat([
      ["language",
       "welcome",
       "identify",
       "registration"],
      symptom_steps(campaign),
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

  def chat_text_for(%{chat_texts: chat_texts}, topic) do
    Enum.find_value(chat_texts, fn([t, _, chat_text]) -> t == topic && chat_text end)
  end
  def chat_text_for(%{chat_texts: chat_texts}, topic, language) do
    Enum.find_value(chat_texts, fn([t, l, chat_text]) -> t == topic && l == language && chat_text end)
  end

  def with_message(campaign, options = %{mode: "call"}), do: with_audio(campaign, options)
  def with_message(campaign, options = %{mode: "chat"}), do: with_chat_text(campaign, options)

  def with_audio(campaign = %{audios: audios}, %{topic: topic, language: language, value: audio_id}) do
    new_audios = replace_or_add_message(audios, topic, language, audio_id)
    %{ campaign | audios: new_audios }
  end

  def with_chat_text(campaign = %{chat_texts: chat_texts}, %{topic: topic, language: language, value: chat_text}) do
    new_chat_texts = replace_or_add_message(chat_texts, topic, language, chat_text)
    %{ campaign | chat_texts: new_chat_texts }
  end
  def with_chat_text(campaign, %{topic: topic, value: chat_text}), do: with_chat_text(campaign, %{topic: topic, language: nil, value: chat_text})

  defp replace_or_add_message([], topic, language, new_value), do: [[topic, language, new_value]]
  defp replace_or_add_message([[topic, language, _value] | tail], topic, language, new_value), do: [[topic, language, new_value] | tail]
  defp replace_or_add_message([head | tail], topic, language, new_value), do: [ head | replace_or_add_message(tail, topic, language, new_value)]

  def with_welcome(campaign, %{mode: "call", language: l, value: v}), do: with_audio(campaign, %{topic: "welcome", language: l, value: v})
  def with_welcome(campaign, %{mode: "chat", language: l, value: v}), do: with_chat_text(campaign, %{topic: "welcome", language: l, value: v})

  def welcome(campaign, %{mode: "chat", language: l}), do: chat_text_for(campaign, "welcome", l)
  def welcome(campaign, %{mode: "call", language: l}), do: audio_for(campaign, "welcome", l)

  def topics(campaign) do
    campaign.symptoms
    |> Enum.map(fn([id, _]) -> "symptom:#{id}" end)
    |> Enum.concat(["welcome", "identify", "registration", "forward", "additional_information_intro", "educational", "thanks"])
  end

  def set_up_verboice(campaign) do
    base_url = "https://verboice-stg.instedd.org"
    Verboice.Client.new(base_url,ActiveMonitoring.OAuthTokenServer.get_token("verboice", base_url, campaign.user_id))
    Verboice.Client.create_project("Active Monitoring set up", %{
      status_callback_url: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :status_callback, campaign.id),
      user: "",
      password: "",
      external_service: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, campaign.id)}
    )
  end

  def mark_as_reminded(campaign, now) do
    changeset(campaign, %{last_reminder_time: now})
    |> Repo.update!
  end

  def subjects_pending_check_in(%Campaign{timezone: timezone}, subjects, now) do
    subjects |> Enum.filter(fn(s) -> Subject.active_case(s, now) && has_not_checked_in_today(timezone, Subject.last_successful_call_date(s), now) end)
  end

  def ready_to_launch?(campaign) do
    case campaign.mode do
      "call" -> Channel.verify_exclusive(campaign.channel)
      "chat" -> not(is_nil(campaign.fb_access_token)) && not(is_nil(campaign.fb_page_id)) && not(is_nil(campaign.fb_verify_token))
      _ -> false
    end
  end

  def load(conn, id) do
    Repo.get!(Campaign, id) |> User.Helper.authorize_campaign(conn)
  end

  def launch(campaign) do
    if ready_to_launch?(campaign) do
      change =
        changeset(campaign, %{})
        |> Ecto.Changeset.put_change(:started_at, Ecto.DateTime.utc())

        if campaign.mode == "chat" do
          result =
            campaign
            |> AidaBot.manifest()
            |> AidaBot.publish()

          case result do
            %{"id" => bot_id} ->
              change
              |> Ecto.Changeset.put_change(:aida_bot_id, bot_id)
              |> Repo.update()

            response ->
              error = "Unknown response publishing manifest: #{inspect(response)}"
              Logger.error(error)
              {:error, %{errors: %{manifest: error}}}
          end
        else
          change
          |> Repo.update()
        end

    else
      {:error, %{errors: %{channel: "already in use"}}}
    end
  end

  defp has_not_checked_in_today(_, nil, _), do: true
  defp has_not_checked_in_today(timezone, last_call_date, now) do
    Timex.before?(Timezone.convert(last_call_date, timezone), Timex.beginning_of_day(Timezone.convert(now, timezone)))
  end

  defp validate_mode(changeset) do
    validate_change changeset, :mode, fn :mode, mode ->
      if mode == "call" || mode == "chat" do
        []
      else
        [mode: "must be either 'call' or 'chat', #{mode} is not allowed"]
      end
    end
  end

  #defp default_mode(changeset = %{mode: nil}), do: %{ changeset | mode: "call" }
  defp default_mode(changeset) do
    case changeset.changes[:mode] do
      "chat" -> change(changeset, %{mode: "chat"})
      "call" -> change(changeset, %{mode: "call"})
      _mode -> changeset
    end
  end
end
