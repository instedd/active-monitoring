defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.Campaign

  def publish(manifest) do
    HTTPoison.post(
      "#{Application.get_env(:active_monitoring, :aida_backend)[:url]}/api/bots",
      manifest
    )
    |> Poison.decode!()
    |> Map.get("data")
  end

  def update(manifest, bot_id) do
    HTTPoison.put(
      "#{Application.get_env(:active_monitoring, :aida_backend)[:url]}/api/bots/#{bot_id}",
      manifest
    )
    |> Poison.decode!()
    |> Map.get("data")
  end

  def manifest(campaign, subjects \\ %{}) do
    %{
      version: "1",
      languages: campaign.langs,
      front_desk: front_desk(campaign),
      skills: skills(campaign, subjects),
      channels: channels(campaign)
    }
    |> Poison.encode!()
  end

  defp front_desk(campaign) do
    %{
      greeting: %{
        message: %{
          en: campaign |> Campaign.welcome(%{mode: "chat", language: "en"}),
          es: campaign |> Campaign.welcome(%{mode: "chat", language: "es"})
        }
      }
    }
  end

  defp channels(campaign) do
    %{
      fb_page_id: fb_page_id,
      fb_verify_token: fb_verify_token,
      fb_access_token: fb_access_token
    } = campaign

    [
      %{
        "type" => "facebook",
        "page_id" => fb_page_id,
        "verify_token" => fb_verify_token,
        "access_token" => fb_access_token
      },
      %{
        "type" => "websocket",
        "access_token" => fb_access_token
      }
    ]
  end

  defp skills(campaign, subjects) do
    language_detector(campaign) ++ registration(campaign) ++ survey(campaign, subjects)
  end

  defp language_detector(%{langs: [_]}), do: []

  defp language_detector(campaign) do
    [
      %{
        explanation: campaign |> Campaign.chat_text_for("language"),
        languages:
          localize(campaign, fn lang ->
            [lang]
          end),
        type: "language_detector"
      }
    ]
  end

  defp registration(campaign) do
    [
      %{
        type: "survey",
        id: "registration",
        name: campaign.name,
        keywords:
          localize(campaign, fn _ ->
            ["registration"]
          end),
        questions: [
          %{
            "type" => "text",
            "name" => "registration_id",
            "message" =>
              localize(campaign, fn lang ->
                campaign |> Campaign.chat_text_for("registration", lang)
              end)
          }
        ]
        |> Enum.concat(thanks_note(campaign))
      }
    ]
  end

  defp survey(%{monitor_duration: monitor_duration} = campaign, subjects) do
    1..monitor_duration
    |> Enum.reduce([], fn campaign_day, surveys ->
      survey(surveys, campaign, subjects |> Map.get(campaign_day), campaign_day)
    end)
  end

  defp survey(surveys, _, nil, _), do: surveys

  defp survey(surveys, %{name: name} = campaign, subjects, campaign_day) do
    surveys ++
      [
        %{
          type: "survey",
          id: "#{campaign_day}",
          name: name,
          schedule: DateTime.utc_now() |> DateTime.to_iso8601(),
          relevant: survey_relevance(subjects),
          questions: questions(campaign),
          choice_lists: [
            %{
              name: "yes_no",
              choices: [
                %{
                  name: "yes",
                  labels: %{
                    en: ["yes"],
                    es: ["yes"]
                  }
                },
                %{
                  name: "no",
                  labels: %{
                    en: ["no"],
                    es: ["no"]
                  }
                }
              ]
            }
          ]
        }
      ]
  end

  defp survey_relevance(nil), do: nil

  defp survey_relevance(subjects) do
    subjects
    |> Enum.map(fn subject -> subject.registration_identifier end)
    |> Enum.map(fn registration_identifier ->
      "${registration_id} == #{registration_identifier}"
    end)
    |> Enum.join(" || ")
  end

  defp questions(%{symptoms: symptoms} = campaign) do
    symptoms
    |> Enum.map(fn [symptom_id, _label] ->
      %{
        "type" => "select_one",
        "choices" => "yes_no",
        "name" => "symptom:#{symptom_id}",
        "message" =>
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("symptom:#{symptom_id}", lang)
          end)
      }
    end)
    |> Enum.concat(additional_information(campaign))
    |> Enum.concat(educational_note(campaign))
    |> Enum.concat(thanks_note(campaign))
  end

  defp additional_information(%{additional_information: "optional"} = campaign) do
    [
      %{
        "type" => "note",
        "name" => "additional_information_intro",
        "message" =>
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("additional_information_intro", lang)
          end)
      }
    ]
  end

  defp additional_information(_), do: []

  defp educational_note(campaign) do
    [
      %{
        "type" => "note",
        "name" => "educational",
        "message" =>
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("educational", lang)
          end)
      }
    ]
  end

  defp thanks_note(campaign) do
    [
      %{
        "type" => "note",
        "name" => "thanks",
        "message" =>
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("thanks", lang)
          end)
      }
    ]
  end

  defp localize(%{langs: langs}, func) do
    langs
    |> Enum.map(fn lang ->
      {lang, func.(lang)}
    end)
    |> Enum.into(%{})
  end
end
