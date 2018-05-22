defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.{Campaign, Repo, Call, CallAnswer, Subject}

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

  def manifest(campaign, active_subjects_per_day \\ %{}, campaign_subjects \\ []) do
    %{
      version: "1",
      languages: campaign.langs,
      front_desk: front_desk(campaign),
      skills: skills(campaign, active_subjects_per_day, campaign_subjects),
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

  defp skills(campaign, active_subjects_per_day, campaign_subjects) do
    language_detector(campaign) ++
      registration(campaign, campaign_subjects) ++ survey(campaign, active_subjects_per_day)
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

  defp registration(campaign, []) do
    [
      %{
        type: "keyword_responder",
        id: "registration",
        name: "registration",
        explanation:
          localize(campaign, fn lang ->
            campaign |> Campaign.welcome(%{mode: "chat", language: lang})
          end),
        clarification:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("registration", lang)
          end),
        keywords:
          localize(campaign, fn _ ->
            ["registration"]
          end),
        response:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("registration", lang)
          end)
      }
    ]
  end

  defp registration(campaign, subjects) do
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
              type: "select_one",
              choices: "registration",
              name: "registration_id",
              message:
                localize(campaign, fn lang ->
                  campaign |> Campaign.chat_text_for("identify", lang)
                end),
              constraint_message:
                localize(campaign, fn lang ->
                  campaign |> Campaign.chat_text_for("registration", lang)
                end)
            }
          ]
          |> Enum.concat(thanks_note(campaign)),
        choice_lists: registration_choices(campaign, subjects)
      }
    ]
  end

  defp registration_choices(campaign, subjects) do
    [
      %{
        name: "registration",
        choices:
          subjects
          |> Enum.map(fn subject ->
            %{
              name: subject.registration_identifier,
              labels:
                localize(campaign, fn _lang ->
                  [subject.registration_identifier]
                end)
            }
          end)
      }
    ]
  end

  defp survey(campaign, subjects_by_day) do
    survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

    schedule =
      Timex.Timezone.resolve(campaign.timezone, survey_start)
      |> DateTime.to_iso8601()

    Enum.reduce(subjects_by_day, [], fn {campaign_day, subjects}, surveys ->
      survey(surveys, campaign, subjects, campaign_day, schedule)
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
          questions: questions(campaign, campaign_day),
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
      "${survey\/registration\/registration_id} = \"#{registration_identifier}\""
    end)
    |> Enum.join(" or ")
  end

  defp questions(%{symptoms: symptoms} = campaign, campaign_day) do
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
    |> Enum.concat(additional_information(campaign, campaign_day))
    |> Enum.concat(thanks_note(campaign))
  end

  defp additional_information(%{additional_information: "optional"} = campaign, campaign_day) do
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
        relevant: "${survey\/#{campaign_day}\/additional_information} = 'yes'",
        message:
          localize(campaign, fn lang ->
            campaign |> Campaign.chat_text_for("educational", lang)
          end)
      }
    ]
  end

  defp additional_information(%{additional_information: "compulsory"} = campaign, _) do
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

  defp additional_information(_, _), do: []

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

  def subject_answers(campaign, sessions) do
    sessions
    |> Enum.filter(fn %{"data" => session_data} ->
      session_data["survey/registration/registration_id"] != nil
    end)
    |> Map.new(fn %{"data" => session_data} ->
      %{"survey/registration/registration_id" => registration_id} = session_data

      {registration_id, calls_in_session(session_data, campaign)}
    end)
  end

  def subject_by_registration_identifier(subjects, identifier) do
    Enum.find(subjects, fn %{registration_identifier: registration_identifier} ->
      registration_identifier == identifier
    end)
  end

  def known_subjects_answers(answers, subjects) do
    known_subjects_registration_identifiers =
      subjects
      |> Enum.map(fn %{registration_identifier: registration_identifier} ->
        registration_identifier
      end)

    answers
    |> Enum.filter(fn {registration_identifier, _calls_data} ->
      Enum.member?(known_subjects_registration_identifiers, registration_identifier)
    end)
    |> Enum.map(fn {registration_identifier, calls_data} ->
      {subject_by_registration_identifier(subjects, registration_identifier), calls_data}
    end)
    |> Map.new()
  end

  def with_needs_to_be_forwarded(call_changes, %{forwarding_condition: "any"}, answers) do
    if (answers |> Enum.any?(fn {_symptom, answer} -> answer end)) do
      Map.put(call_changes, :needs_to_be_forwarded, true)
    else
      call_changes
    end
  end

  def with_needs_to_be_forwarded(%{current_step: "thanks"} = call_changes, %{forwarding_condition: "all"}, answers) do
    if (answers |> Enum.all?(fn {_symptom, answer} -> answer end)) do
      Map.put(call_changes, :needs_to_be_forwarded, true)
    else
      call_changes
    end
  end
  def with_needs_to_be_forwarded(call_changes, %{forwarding_condition: "all"}, _answers), do: call_changes

  def create_missing_calls_and_answers(answers_by_subject, campaign) do
    answers_by_subject
    |> Enum.each(fn {subject, subject_data} ->
      language = subject_data["language"]

      full_name = subject_data["full_name"]

      subject = if subject.contact_address != full_name do
        Subject.changeset(subject, %{contact_address: full_name}) |> Repo.update!
      else
        subject
      end

      subject_data["answers"]
      |> Enum.each(fn {day, answer} ->
        %{"current_step" => current_step, "symptoms" => symptoms} = answer

        call_changes = with_needs_to_be_forwarded(%{
          campaign_id: subject.campaign_id,
          language: language,
          subject_id: subject.id,
          current_step: current_step,
          inserted_at: date_for_monitoring_index(subject, day)
        }, campaign, symptoms)

        %{id: call_id} =
          Call.changeset(
            %Call{},
            call_changes
          )
          |> Repo.insert!(
            on_conflict: [set: [current_step: current_step]],
            conflict_target: [:subject_id, :inserted_at, :campaign_id]
          )

        Enum.each(symptoms, fn {symptom, answer} ->
          CallAnswer.changeset(%CallAnswer{}, %{
            call_id: call_id,
            campaign_id: subject.campaign_id,
            symptom: symptom,
            response: answer
          })
          |> Repo.insert!(on_conflict: :nothing)
        end)
      end)
    end)
  end

  def retrieve_responses(%{aida_bot_id: aida_bot_id} = campaign) do
    {:ok, response} =
      "#{Application.get_env(:active_monitoring, :aida_backend)[:url]}/api/bots/#{aida_bot_id}/session_data?include_internal=true"
      |> HTTPoison.get()

    body = response.body |> parse_response

    subject_answers(campaign, body["data"])
    |> known_subjects_answers(campaign.subjects)
    |> create_missing_calls_and_answers(campaign)
  end

  defp parse_boolean(text) do
    text == "yes"
  end

  defp current_step(response, day, campaign) do
    in_progress = Map.get(response, ".survey/#{day}")

    case in_progress do
      %{"step" => step} -> campaign |> Campaign.chat_steps() |> Enum.at(step - 1)
      _ -> "thanks"
    end
  end

  defp call_data(response, day, campaign, payload) do
    default = %{"current_step" => "thanks", "symptoms" => %{}}

    payload =
      payload
      |> Enum.reduce(default, fn element, reduced ->
        case element do
          %{current_step: current_step} ->
            %{reduced | "current_step" => current_step}

          %{answer: answer, symptom: symptom} ->
            %{reduced | "symptoms" => Map.put(reduced["symptoms"], symptom, answer)}
        end
      end)

    %{"current_step" => current_step(response, day, campaign), "symptoms" => payload["symptoms"]}
  end

  defp calls_in_session(response, campaign) do
    language = response["language"]
    first_name = response["first_name"]
    last_name = response["last_name"]
    regex = ~r"^survey\/(\d+)\/symptom:([\w-]+)"

    all_answers =
      Enum.map(response, fn {key, v} ->
        case Regex.run(regex, key) do
          [_, i, symptom] ->
            %{day: String.to_integer(i), payload: %{symptom: symptom, answer: parse_boolean(v)}}

          nil ->
            case Regex.run(~r"^\.survey\/(\d+)", key) do
              [_, i] -> %{day: String.to_integer(i), payload: %{current_step: v[:step]}}
              _ -> nil
            end
        end
      end)

    all_answers =
      all_answers
      |> Enum.reject(&is_nil/1)
      |> Enum.group_by(fn %{day: day} -> day end, fn %{payload: payload} -> payload end)
      |> Map.new(fn {day, payload} -> {day, call_data(response, day, campaign, payload)} end)

    with_full_name_if_present(%{"language" => language, "answers" => all_answers}, first_name, last_name)
  end

  defp with_full_name_if_present(session_info, nil, nil), do: session_info
  defp with_full_name_if_present(session_info, nil, last_name), do: Map.put(session_info, "full_name", last_name)
  defp with_full_name_if_present(session_info, first_name, nil), do: Map.put(session_info, "full_name", first_name)
  defp with_full_name_if_present(session_info, first_name, last_name), do: Map.put(session_info, "full_name", "#{first_name} #{last_name}")

  def date_for_monitoring_index(subject, day) do
    Subject.enroll_date(subject)
    |> Timex.shift(days: day - 1)
  end

  defp parse_response(response) do
    Poison.decode!(response)
  end
end
