defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.{Campaign, Repo}

  def publish(manifest) do
    HTTPoison.post(Application.get_env(:active_monitoring, :aida_backend)[:url], manifest)
  end

  def manifest(campaign) do
    campaign =
      campaign
      |> Repo.preload(:subjects)

    %{
      version: "1",
      languages: campaign.langs,
      front_desk: %{
        greeting: %{
          message: %{
            en: campaign |> Campaign.welcome(%{mode: "chat", language: "en"}),
            es: campaign |> Campaign.welcome(%{mode: "chat", language: "es"})
          }
        }
      },
      skills: [
        %{
          explanation: campaign |> Campaign.chat_text_for("language"),
          languages:
            localize(campaign, fn lang ->
              [lang]
            end),
          type: "language_detector"
        },
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
        },
        %{
          type: "survey",
          id: "survey",
          name: campaign.name,
          schedule: DateTime.utc_now() |> DateTime.to_iso8601(),
          relevant:
            if campaign.subjects == [] do
              nil
            else
              campaign.subjects
              |> Enum.map(fn subject -> subject.registration_identifier end)
              |> Enum.map(fn registration_identifier ->
                "${registration_id} == #{registration_identifier}"
              end)
              |> Enum.join(" || ")
            end,
          questions:
            campaign.symptoms
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
            end),
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
    }
    |> Poison.encode!()
  end

  defp localize(campaign, func) do
    campaign.langs
    |> Enum.map(fn lang ->
      {lang, func.(lang)}
    end)
    |> Enum.into(%{})
  end
end
