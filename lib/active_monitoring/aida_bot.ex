defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.Campaign

  def publish(manifest) do
    {:ok, response} =
      HTTPoison.post(
        "#{Application.get_env(:active_monitoring, :aida_backend)[:url]}/api/bots",
        %{bot: %{manifest: manifest}} |> Poison.encode!(),
        [{'Accept', 'application/json'}, {"Content-Type", "application/json"}]
      )

    response.body
    |> Poison.decode!()
    |> Map.get("data")
  end

  def update(manifest, bot_id) do
    {:ok, response} =
      HTTPoison.put(
        "#{Application.get_env(:active_monitoring, :aida_backend)[:url]}/api/bots/#{bot_id}",
        %{bot: %{manifest: manifest}} |> Poison.encode!(),
        [{'Accept', 'application/json'}, {"Content-Type", "application/json"}]
      )

    response.body
    |> Poison.decode!()
    |> Map.get("data")
  end

  def manifest(campaign, subjects \\ %{}) do
    %{
      version: "1",
      languages: campaign.langs,
      front_desk: front_desk(campaign),
      skills: skills(campaign, subjects),
      channels: channels(campaign),
      variables: []
    }
  end

  defp front_desk(campaign) do
    %{
      greeting: %{
        message:
          localize(campaign, fn _lang ->
            "Hello!"
          end)
      },
      introduction: %{
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.welcome(%{mode: "chat", language: lang})
          end)
      },
      not_understood: %{
        message:
          localize(campaign, fn _lang ->
            "Sorry, I did not understood that"
          end)
      },
      clarification: %{
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("registration", lang)
          end)
      },
      threshold: 0.5
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
        type: "facebook",
        page_id: fb_page_id,
        verify_token: fb_verify_token,
        access_token: fb_access_token
      },
      %{
        type: "websocket",
        access_token: fb_access_token
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
        name: "registration",
        keywords:
          localize(campaign, fn _ ->
            ["registration"]
          end),
        questions:
          [
            %{
              type: "text",
              name: "registration_id",
              message:
                localize(campaign, fn lang ->
                  campaign |> Campaign.chat_text_for("identify", lang)
                end)
            }
          ]
          |> Enum.concat(thanks_note(campaign)),
        choice_lists: []
      }
    ]
  end

  defp survey(%{monitor_duration: monitor_duration} = campaign, subjects) do
    survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

    schedule =
      Timex.Timezone.resolve(campaign.timezone, survey_start)
      |> DateTime.to_iso8601()

    1..monitor_duration
    |> Enum.reduce([], fn campaign_day, surveys ->
      survey(surveys, campaign, subjects |> Map.get(campaign_day), campaign_day, schedule)
    end)
  end

  defp survey(surveys, _campaign, nil, _campaign_day, _schedule), do: surveys

  defp survey(surveys, campaign, subjects, campaign_day, schedule) do
    surveys ++
      [
        %{
          type: "survey",
          id: "#{campaign_day}",
          name: "survey_#{campaign_day}",
          schedule: schedule,
          relevant: survey_relevance(subjects),
          questions: questions(campaign),
          choice_lists: [
            %{
              name: "yes_no",
              choices: [
                %{
                  name: "yes",
                  labels:
                    localize(campaign, fn _lang ->
                      ["yes"]
                    end)
                },
                %{
                  name: "no",
                  labels:
                    localize(campaign, fn _lang ->
                      ["no"]
                    end)
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
      "${registration_id} = #{registration_identifier}"
    end)
    |> Enum.join(" or ")
  end

  defp questions(%{symptoms: symptoms} = campaign) do
    symptoms
    |> Enum.map(fn [symptom_id, _label] ->
      %{
        type: "select_one",
        choices: "yes_no",
        name: "symptom:#{symptom_id}",
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("symptom:#{symptom_id}", lang)
          end)
      }
    end)
    |> Enum.concat(additional_information(campaign))
    |> Enum.concat(thanks_note(campaign))
  end

  defp additional_information(%{additional_information: "optional"} = campaign) do
    [
      %{
        type: "select_one",
        choices: "yes_no",
        name: "additional_information",
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("additional_information_intro", lang)
          end)
      },
      %{
        type: "note",
        name: "educational",
        relevant: "${additional_information} == 'yes'",
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("educational", lang)
          end)
      }
    ]
  end

  defp additional_information(%{additional_information: "compulsory"} = campaign) do
    [
      %{
        type: "note",
        name: "educational",
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("educational", lang)
          end)
      }
    ]
  end

  defp additional_information(_), do: []

  defp thanks_note(campaign) do
    [
      %{
        type: "note",
        name: "thanks",
        message:
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
