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
      forwarding_number: "5550000",
      symptoms: [["id-fever", "Fever"], ["id-rash", "Rash"]],
      langs: ["en", "es"],
      audios: [],
      additional_information: "compulsory",
      user: build(:user)
    }
  end

  def with_audios(campaign) do
    topics =
      campaign.symptoms
      |> Enum.map(fn([id, _]) -> "symptom:#{id}" end)
      |> Enum.concat(["welcome", "forward", "additional_information_intro", "educational", "thanks"])

    lang_audios =
      for lang <- campaign.langs,
          topic <- topics,
          do: [topic, lang, "id-#{topic}-#{lang}"]

    audios =
      [["language", nil, "id-language"] | lang_audios]

    %{campaign | audios: audios}
  end

  def with_channel(campaign) do
    %{campaign | channel: "channel_name"}
  end

  def subject_factory do
    %Subject{
      phone_number: sequence(:phone_number, &"555#{&1 |> Integer.to_string |> String.pad_leading(4, "0")}"),
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
      symptom: "id-fever",
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
