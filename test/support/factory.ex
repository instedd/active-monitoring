defmodule ActiveMonitoring.Factory do
  use ExMachina.Ecto, repo: ActiveMonitoring.Repo

  alias ActiveMonitoring.{User, Campaign, Call, CallAnswer, Subject}

  def user_factory do
    %User{
      name: "Jane Smith",
      email: sequence(:email, &"email-#{&1}@example.com"),
    }
  end

  def campaign_factory do
    %Campaign{
      name: "Campaign",
      forwarding_condition: "all",
      forwarding_address: "5550000",
      symptoms: [["123e4567-e89b-12d3-a456-426655440111", "Fever"], ["123e4567-e89b-12d3-a456-426655440222", "Rash"]],
      langs: ["en", "es"],
      audios: [],
      chat_texts: [],
      additional_information: "compulsory",
      monitor_duration: 30,
      timezone: "Europe/London",
      user: build(:user),
      aida_bot_id: "123e4567-e89b-12d3-a456-426655440000",
      mode: "call"
    }
  end

  def with_audios(campaign) do
    topics = Campaign.topics(campaign)

    lang_audios =
      for lang <- campaign.langs,
          topic <- topics,
          do: [topic, lang, "id-#{topic}-#{lang}"]

    audios =
      [["language", nil, "id-language"] | lang_audios]

    %{campaign | audios: audios}
  end

  def with_chat_texts(campaign) do
    topics = Campaign.topics(campaign)

    entries =
      for lang <- campaign.chat_texts,
          topic <- topics,
          do: [topic, lang, "id-#{topic}-#{lang}"]

    values =
      [["language", nil, "id-language"] | entries]

    campaign |> Map.put(:chat_texts, values)
  end

  def with_channel(campaign) do
    %{campaign | channel: "channel_name"}
  end

  def subject_factory do
    %Subject{
      contact_address: sequence(:contact_address, &"555#{&1 |> Integer.to_string |> String.pad_leading(4, "0")}"),
      registration_identifier: sequence(:registration_identifier, fn(n) -> n |> Integer.to_string |> String.pad_leading(8, "0") end),
      campaign: build(:campaign)
    }
  end

  def call_factory do
    %Call{
      sid: sequence("sid"),
      from: "9990001",
      campaign: build(:campaign)
    }
  end

  def on_step(call, step) do
    %{call | current_step: step}
  end

  def call_answer_factory do
    %CallAnswer{
      symptom: "123e4567-e89b-12d3-a456-426655440111",
      response: true
    }
  end

  def for_call(call_answer, call) do
    %{call_answer | call: call, campaign: call.campaign}
  end

  def oauth_token_factory do
    %ActiveMonitoring.OAuthToken{
      provider: "verboice",
      base_url: "http://test.com",
      user: build(:user),
      access_token: %{
        "access_token" => :crypto.strong_rand_bytes(27) |> Base.encode64,
      },
      expires_at: Timex.now |> Timex.add(Timex.Duration.from_hours(1))
    }
  end


end
