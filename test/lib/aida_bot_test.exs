defmodule ActiveMonitoring.AidaBotTest do
  use ActiveMonitoring.ModelCase
  use Timex
  import ActiveMonitoring.Factory
  import Mock

  alias ActiveMonitoring.{AidaBot, Campaign, Call, Subject}

  defp with_campaign(_) do
    [campaign: insert(:campaign) |> Repo.preload(:subjects)]
  end

  defp with_campaign_subjects(_) do
    campaign = insert(:campaign)
    subject = insert(:subject, campaign: campaign)
    [subject: subject, campaign: (campaign |> Repo.preload(:subjects))]
  end

  defp with_subject_calls(%{campaign: campaign, subject: subject}) do
    call =
      insert(
        :call,
        campaign: campaign,
        subject: subject,
        inserted_at: AidaBot.date_for_monitoring_index(subject, 1)
      )

    [call: call]
  end

  defp retrieve_mocked_campaign_data(%{aida_bot_id: bot_id} = campaign, data) do
    with_mock HTTPoison, get: fn _url -> {:ok, %HTTPoison.Response{body: Poison.encode!(%{"data" => data})}} end do
      AidaBot.retrieve_responses(campaign)
      assert called(HTTPoison.get("http://aida-backend/api/bots/#{bot_id}/session_data?include_internal=true"))
    end
  end

  describe "manifest" do
    setup [:with_campaign]

    test "it should be a version 1 manifest", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()

      assert manifest[:version] == "1"
    end

    test "it takes languages from campaign", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()

      assert manifest[:languages] == ["en", "es"]
    end

    test "there is a greeting for each language", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()

      assert manifest[:front_desk][:greeting][:message] == %{
               "en" => "Hello!",
               "es" => "Hello!"
             }
    end

    test "there is a not_understood message for each language", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()

      assert manifest[:front_desk][:not_understood][:message] == %{
               "en" => "Sorry, I did not understood that",
               "es" => "Sorry, I did not understood that"
             }
    end

    test "there is a clarification message for each language", context do
      manifest =
        context[:campaign]
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "en",
          value: "Send \"registration\" to register for the campaign"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "es",
          value: "Envíe \"registration\" para registrarse a la campaña"
        })
        |> AidaBot.manifest()

      assert manifest[:front_desk][:clarification][:message] == %{
               "en" => "Send \"registration\" to register for the campaign",
               "es" => "Envíe \"registration\" para registrarse a la campaña"
             }
    end

    test "there is an introduction message for each language", context do
      manifest =
        context[:campaign]
        |> Campaign.with_welcome(%{
          mode: "chat",
          language: "en",
          value: "Welcome to the campaign!"
        })
        |> Campaign.with_welcome(%{
          mode: "chat",
          language: "es",
          value: "Bienvenidos a la campaña!"
        })
        |> AidaBot.manifest()

      assert manifest[:front_desk][:introduction][:message] == %{
               "en" => "Welcome to the campaign!",
               "es" => "Bienvenidos a la campaña!"
             }
    end

    test "there is a language detector skill" do
      manifest =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "language",
          value: "To chat in english say 'en'. Para hablar en español escribe 'es'"
        })
        |> AidaBot.manifest()

      {:ok, skill} = manifest[:skills] |> Enum.fetch(0)

      assert skill == %{
               type: "language_detector",
               explanation: "To chat in english say 'en'. Para hablar en español escribe 'es'",
               languages: %{
                 "en" => ["en"],
                 "es" => ["es"]
               }
             }
    end

    test "there is no language detector skill if the campaign has only one language" do
      manifest =
        insert(:campaign, %{langs: ["en"]})
        |> Campaign.with_chat_text(%{
          topic: "language",
          value: "To chat in english say 'en'. Para hablar en español escribe 'es'"
        })
        |> AidaBot.manifest()

      assert manifest[:skills] |> Enum.count() == 1

      {:ok, skill} = manifest[:skills] |> Enum.fetch(0)

      assert skill[:type] == "keyword_responder"
    end

    test "it should have a survey with a text question to ask for the registration identifier" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "identify",
          language: "en",
          value: "Please tell me your Registration Id"
        })
        |> Campaign.with_chat_text(%{
          topic: "identify",
          language: "es",
          value: "Por favor dígame su número de registro"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "es",
          value: "gracias!"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "en",
          value:
            "Send \"registration\" to register for the campaign or call 1234567890 to get your registration id"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "es",
          value:
            "Envíe \"registration\" para registrarse a la campaña o llame al 1234567890 para obtener su identificador de registro"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      manifest =
        campaign
        |> AidaBot.manifest(%{}, [subject1, subject2])

      {:ok, skill} = manifest[:skills] |> Enum.fetch(1)

      assert skill == %{
               type: "survey",
               id: "registration",
               name: "registration",
               keywords: %{
                 "en" => ["registration"],
                 "es" => ["registration"]
               },
               questions: [
                 %{
                   type: "select_one",
                   choices: "registration",
                   name: "registration_id",
                   message: %{
                     "en" => "Please tell me your Registration Id",
                     "es" => "Por favor dígame su número de registro"
                   },
                   constraint_message: %{
                     "en" =>
                       "Send \"registration\" to register for the campaign or call 1234567890 to get your registration id",
                     "es" =>
                       "Envíe \"registration\" para registrarse a la campaña o llame al 1234567890 para obtener su identificador de registro"
                   }
                 },
                 %{
                   type: "note",
                   name: "thanks",
                   message: %{
                     "en" => "thanks!",
                     "es" => "gracias!"
                   }
                 }
               ],
               choice_lists: [
                 %{
                   name: "registration",
                   choices: [
                     %{
                       name: "#{subject1.registration_identifier}",
                       labels: %{
                         "en" => ["#{subject1.registration_identifier}"],
                         "es" => ["#{subject1.registration_identifier}"]
                       }
                     },
                     %{
                       name: "#{subject2.registration_identifier}",
                       labels: %{
                         "en" => ["#{subject2.registration_identifier}"],
                         "es" => ["#{subject2.registration_identifier}"]
                       }
                     }
                   ]
                 }
               ]
             }
    end

    test "it shouldn't have a registration survey if there are no subjects" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_welcome(%{
          mode: "chat",
          language: "en",
          value: "Please send 'registration' to register"
        })
        |> Campaign.with_welcome(%{
          mode: "chat",
          language: "es",
          value: "Por favor envíe 'registration' para registrarse"
        })
        |> Campaign.with_chat_text(%{
          topic: "identify",
          language: "en",
          value: "Please tell me your Registration Id"
        })
        |> Campaign.with_chat_text(%{
          topic: "identify",
          language: "es",
          value: "Por favor dígame su número de registro"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "es",
          value: "gracias!"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "en",
          value: "Contact 1234567890"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "es",
          value: "Contacte al 1234567890"
        })

      manifest =
        campaign
        |> AidaBot.manifest()

      assert manifest[:skills] |> Enum.count() == 2

      {:ok, skill} = manifest[:skills] |> Enum.fetch(1)

      assert skill == %{
               type: "keyword_responder",
               id: "registration",
               name: "registration",
               explanation: %{
                 "en" => "Please send 'registration' to register",
                 "es" => "Por favor envíe 'registration' para registrarse"
               },
               clarification: %{
                 "en" => "Contact 1234567890",
                 "es" => "Contacte al 1234567890"
               },
               keywords: %{
                 "en" => ["registration"],
                 "es" => ["registration"]
               },
               response: %{
                 "en" => "Contact 1234567890",
                 "es" => "Contacte al 1234567890"
               }
             }
    end

    test "it shouldn't have a survey without active subjects" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "es",
          value: "¿Tiene usted fiebre?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "es",
          value: "¿Tiene alguna erupción?"
        })

      manifest =
        campaign
        |> AidaBot.manifest()

      assert manifest[:skills] |> Enum.count() == 2

      {:ok, skill} = manifest[:skills] |> Enum.fetch(0)
      assert skill[:type] == "language_detector"

      {:ok, skill} = manifest[:skills] |> Enum.fetch(1)
      assert skill[:type] == "keyword_responder"
    end

    test "surveys should have a question for every symptom" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"], additional_information: nil})
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "es",
          value: "¿Tiene usted fiebre?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "es",
          value: "¿Tiene alguna erupción?"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "es",
          value: "Gracias!"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      relevance =
        "${survey\/registration\/registration_id} = \"#{subject1.registration_identifier}\" " <>
          "or ${survey\/registration\/registration_id} = \"#{subject2.registration_identifier}\""

      manifest =
        campaign
        |> AidaBot.manifest(%{1 => [subject1, subject2]}, [subject1, subject2])

      survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

      schedule =
        Timex.Timezone.resolve(campaign.timezone, survey_start)
        |> DateTime.to_iso8601()

      {:ok, skill} = manifest[:skills] |> Enum.fetch(2)

      assert skill ==
               %{
                 type: "survey",
                 id: "1",
                 name: "survey_1",
                 schedule: schedule,
                 relevant: relevance,
                 questions: [
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440111",
                     message: %{
                       "en" => "Do you have fever?",
                       "es" => "¿Tiene usted fiebre?"
                     }
                   },
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440222",
                     message: %{
                       "en" => "Do you have rash?",
                       "es" => "¿Tiene alguna erupción?"
                     }
                   },
                   %{
                     type: "note",
                     name: "thanks",
                     message: %{
                       "en" => "thanks!",
                       "es" => "Gracias!"
                     }
                   }
                 ],
                 choice_lists: [
                   %{
                     name: "yes_no",
                     choices: [
                       %{
                         name: "yes",
                         labels: %{
                           "en" => ["yes"],
                           "es" => ["yes"]
                         }
                       },
                       %{
                         name: "no",
                         labels: %{
                           "en" => ["no"],
                           "es" => ["no"]
                         }
                       }
                     ]
                   }
                 ]
               }
    end

    test "should have one survey per monitor duration day if there is at least one subject for that day" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"], monitor_duration: 3, additional_information: nil})
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "es",
          value: "¿Tiene usted fiebre?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "es",
          value: "¿Tiene alguna erupción?"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "es",
          value: "¡Gracias!"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      subject3 = insert(:subject, campaign: campaign)

      relevance1 =
        "${survey\/registration\/registration_id} = \"#{subject1.registration_identifier}\" " <>
          "or ${survey\/registration\/registration_id} = \"#{subject2.registration_identifier}\""

      relevance3 =
        "${survey\/registration\/registration_id} = \"#{subject3.registration_identifier}\""

      manifest =
        campaign
        |> AidaBot.manifest(
          %{1 => [subject1, subject2], 3 => [subject3]},
          [subject1, subject2, subject3]
        )

      assert manifest[:skills] |> Enum.count() == 4

      survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

      schedule =
        Timex.Timezone.resolve(campaign.timezone, survey_start)
        |> DateTime.to_iso8601()

      {:ok, skill} = manifest[:skills] |> Enum.fetch(2)

      assert skill ==
               %{
                 type: "survey",
                 id: "1",
                 name: "survey_1",
                 schedule: schedule,
                 relevant: relevance1,
                 questions: [
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440111",
                     message: %{
                       "en" => "Do you have fever?",
                       "es" => "¿Tiene usted fiebre?"
                     }
                   },
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440222",
                     message: %{
                       "en" => "Do you have rash?",
                       "es" => "¿Tiene alguna erupción?"
                     }
                   },
                   %{
                     type: "note",
                     name: "thanks",
                     message: %{
                       "en" => "thanks!",
                       "es" => "¡Gracias!"
                     }
                   }
                 ],
                 choice_lists: [
                   %{
                     name: "yes_no",
                     choices: [
                       %{
                         name: "yes",
                         labels: %{
                           "en" => ["yes"],
                           "es" => ["yes"]
                         }
                       },
                       %{
                         name: "no",
                         labels: %{
                           "en" => ["no"],
                           "es" => ["no"]
                         }
                       }
                     ]
                   }
                 ]
               }

      {:ok, skill} = manifest[:skills] |> Enum.fetch(3)

      assert skill ==
               %{
                 type: "survey",
                 id: "3",
                 name: "survey_3",
                 schedule: schedule,
                 relevant: relevance3,
                 questions: [
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440111",
                     message: %{
                       "en" => "Do you have fever?",
                       "es" => "¿Tiene usted fiebre?"
                     }
                   },
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440222",
                     message: %{
                       "en" => "Do you have rash?",
                       "es" => "¿Tiene alguna erupción?"
                     }
                   },
                   %{
                     type: "note",
                     name: "thanks",
                     message: %{
                       "en" => "thanks!",
                       "es" => "¡Gracias!"
                     }
                   }
                 ],
                 choice_lists: [
                   %{
                     name: "yes_no",
                     choices: [
                       %{
                         name: "yes",
                         labels: %{
                           "en" => ["yes"],
                           "es" => ["yes"]
                         }
                       },
                       %{
                         name: "no",
                         labels: %{
                           "en" => ["no"],
                           "es" => ["no"]
                         }
                       }
                     ]
                   }
                 ]
               }
    end

    test "surveys should include optional educational information" do
      campaign =
        insert(:campaign, %{langs: ["en"], additional_information: "optional"})
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "additional_information_intro",
          language: "en",
          value: "additional_information_intro copy"
        })
        |> Campaign.with_chat_text(%{
          topic: "educational",
          language: "en",
          value: "educational copy"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      relevance =
        "${survey\/registration\/registration_id} = \"#{subject1.registration_identifier}\" " <>
          "or ${survey\/registration\/registration_id} = \"#{subject2.registration_identifier}\""

      manifest =
        campaign
        |> AidaBot.manifest(%{1 => [subject1, subject2]}, [subject1, subject2])

      survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

      schedule =
        Timex.Timezone.resolve(campaign.timezone, survey_start)
        |> DateTime.to_iso8601()

      {:ok, skill} = manifest[:skills] |> Enum.fetch(1)

      assert skill == %{
               type: "survey",
               id: "1",
               name: "survey_1",
               schedule: schedule,
               relevant: relevance,
               questions: [
                 %{
                   type: "select_one",
                   choices: "yes_no",
                   name: "symptom:123e4567-e89b-12d3-a456-426655440111",
                   message: %{
                     "en" => "Do you have fever?"
                   }
                 },
                 %{
                   type: "select_one",
                   choices: "yes_no",
                   name: "symptom:123e4567-e89b-12d3-a456-426655440222",
                   message: %{
                     "en" => "Do you have rash?"
                   }
                 },
                 %{
                   type: "select_one",
                   choices: "yes_no",
                   name: "additional_information",
                   message: %{
                     "en" => "additional_information_intro copy"
                   }
                 },
                 %{
                   type: "note",
                   name: "educational",
                   relevant: "${survey\/1\/additional_information} = 'yes'",
                   message: %{
                     "en" => "educational copy"
                   }
                 },
                 %{
                   type: "note",
                   name: "thanks",
                   message: %{
                     "en" => "thanks!"
                   }
                 }
               ],
               choice_lists: [
                 %{
                   name: "yes_no",
                   choices: [
                     %{
                       name: "yes",
                       labels: %{
                         "en" => ["yes"]
                       }
                     },
                     %{
                       name: "no",
                       labels: %{
                         "en" => ["no"]
                       }
                     }
                   ]
                 }
               ]
             }
    end

    test "surveys should include compulsory educational information" do
      campaign =
        insert(:campaign, %{langs: ["en"], additional_information: "compulsory"})
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440111",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:123e4567-e89b-12d3-a456-426655440222",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "additional_information_intro",
          language: "en",
          value: "additional_information_intro copy"
        })
        |> Campaign.with_chat_text(%{
          topic: "educational",
          language: "en",
          value: "educational copy"
        })
        |> Campaign.with_chat_text(%{
          topic: "thanks",
          language: "en",
          value: "thanks!"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      relevance =
        "${survey\/registration\/registration_id} = \"#{subject1.registration_identifier}\" " <>
          "or ${survey\/registration\/registration_id} = \"#{subject2.registration_identifier}\""

      manifest =
        campaign
        |> AidaBot.manifest(%{1 => [subject1, subject2]}, [subject1, subject2])

      survey_start = {Timex.today() |> Timex.to_erl(), {15, 0, 0}}

      schedule =
        Timex.Timezone.resolve(campaign.timezone, survey_start)
        |> DateTime.to_iso8601()

      {:ok, skill} = manifest[:skills] |> Enum.fetch(1)

      assert skill ==
               %{
                 type: "survey",
                 id: "1",
                 name: "survey_1",
                 schedule: schedule,
                 relevant: relevance,
                 questions: [
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440111",
                     message: %{
                       "en" => "Do you have fever?"
                     }
                   },
                   %{
                     type: "select_one",
                     choices: "yes_no",
                     name: "symptom:123e4567-e89b-12d3-a456-426655440222",
                     message: %{
                       "en" => "Do you have rash?"
                     }
                   },
                   %{
                     type: "note",
                     name: "educational",
                     message: %{
                       "en" => "educational copy"
                     }
                   },
                   %{
                     type: "note",
                     name: "thanks",
                     message: %{
                       "en" => "thanks!"
                     }
                   }
                 ],
                 choice_lists: [
                   %{
                     name: "yes_no",
                     choices: [
                       %{
                         name: "yes",
                         labels: %{
                           "en" => ["yes"]
                         }
                       },
                       %{
                         name: "no",
                         labels: %{
                           "en" => ["no"]
                         }
                       }
                     ]
                   }
                 ]
               }
    end

    test "should have a websocket channel and a facebook channel" do
      manifest =
        insert(:campaign, %{
          langs: ["en"],
          fb_page_id: "the_page_id",
          fb_verify_token: "the_verify_token",
          fb_access_token: "the_access_token"
        })
        |> Campaign.with_chat_text(%{
          topic: "language",
          value: "To chat in english say 'en'. Para hablar en español escribe 'es'"
        })
        |> AidaBot.manifest()

      assert manifest[:channels] == [
               %{
                 type: "facebook",
                 page_id: "the_page_id",
                 verify_token: "the_verify_token",
                 access_token: "the_access_token"
               },
               %{
                 type: "websocket",
                 access_token: "the_access_token"
               }
             ]
    end
  end

  describe "poll" do
    setup [:with_campaign]
    test "should poll data from AIDA", %{campaign: campaign} do
      retrieve_mocked_campaign_data(campaign, [])
    end

    test "should find no new sessions on empty answer", %{campaign: campaign} do
      assert AidaBot.subject_answers(campaign, []) == %{}
    end

    test "should ignore sessions without registration ID", %{campaign: campaign} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "en"
          }
        }
      ]

      assert AidaBot.subject_answers(campaign, data) == %{}
    end
  end

  describe "with subjects" do
    setup [:with_campaign_subjects]

    test "should create a new call when AIDA reports a session with an known registration ID", %{
      campaign: campaign,
      subject: subject
    } do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "en",
            "survey/registration/registration_id" => subject.registration_identifier
          }
        }
      ]

      assert AidaBot.subject_answers(campaign, data) == %{
               subject.registration_identifier => %{"answers" => %{}, "language" => "en"}
             }
    end

    test "should create a call with a symptom when AIDA reports a session with a symptom answer",
         %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "en",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "no",
            "survey/4/symptom:123e4567-e89b-12d3-a456-426655440222" => "no",
            "survey/4/symptom:123e4567-e89b-12d3-a456-426655440111" => "yes"
          }
        }
      ]

      assert AidaBot.subject_answers(campaign, data) == %{
               subject.registration_identifier => %{
                 "language" => "en",
                 "answers" => %{
                   1 => %{
                     "current_step" => "thanks",
                     "symptoms" => %{
                       "123e4567-e89b-12d3-a456-426655440111" => false,
                       "123e4567-e89b-12d3-a456-426655440222" => true
                     }
                   },
                   4 => %{
                     "current_step" => "thanks",
                     "symptoms" => %{
                       "123e4567-e89b-12d3-a456-426655440111" => true,
                       "123e4567-e89b-12d3-a456-426655440222" => false
                     }
                   }
                 }
               }
             }
    end
  end

  describe "with subjects and calls" do
    setup [:with_campaign_subjects, :with_subject_calls]

    test "should not create calls for unknown subjects", %{subject: subject} do
      parsed_answers = %{
        subject.registration_identifier => %{
          "language" => "en",
          "answers" => %{
            1 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => false,
                "123e4567-e89b-12d3-a456-426655440222" => true
              }
            },
            4 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => true,
                "123e4567-e89b-12d3-a456-426655440222" => false
              }
            }
          }
        },
        "XXX_NON_EXISTING_REGISTRATION_IDENTIFIER_XXX" => %{
          "language" => "es",
          "answers" => %{
            1 => %{
              "123e4567-e89b-12d3-a456-426655440111" => false,
              "123e4567-e89b-12d3-a456-426655440222" => true
            }
          }
        }
      }

      assert AidaBot.known_subjects_answers(parsed_answers, [subject]) == %{
               subject => %{
                 "language" => "en",
                 "answers" => %{
                   1 => %{
                     "current_step" => "thanks",
                     "symptoms" => %{
                       "123e4567-e89b-12d3-a456-426655440111" => false,
                       "123e4567-e89b-12d3-a456-426655440222" => true
                     }
                   },
                   4 => %{
                     "current_step" => "thanks",
                     "symptoms" => %{
                       "123e4567-e89b-12d3-a456-426655440111" => true,
                       "123e4567-e89b-12d3-a456-426655440222" => false
                     }
                   }
                 }
               }
             }
    end

    test "should not create calls that have already been registered", %{campaign: campaign, subject: subject} do
      known_subjects_answers = %{
        subject => %{
          "language" => "en",
          "answers" => %{
            1 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => false,
                "123e4567-e89b-12d3-a456-426655440222" => true
              }
            },
            4 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => true,
                "123e4567-e89b-12d3-a456-426655440222" => false
              }
            }
          }
        }
      }

      current_calls_count = Repo.one(from(c in "calls", select: count(c.id)))
      AidaBot.create_missing_calls_and_answers(known_subjects_answers, campaign)
      assert Repo.one(from(c in "calls", select: count(c.id))) == current_calls_count + 1
    end

    test "should create missing call answers", %{campaign: campaign, subject: subject} do
      known_subjects_answers = %{
        subject => %{
          "language" => "en",
          "answers" => %{
            1 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => false,
                "123e4567-e89b-12d3-a456-426655440222" => true
              }
            },
            4 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => true,
                "123e4567-e89b-12d3-a456-426655440222" => false
              }
            }
          }
        }
      }

      current_call_answers_count = Repo.one(from(c in "call_answers", select: count(c.id)))
      AidaBot.create_missing_calls_and_answers(known_subjects_answers, campaign)

      assert Repo.one(from(c in "call_answers", select: count(c.id))) ==
               current_call_answers_count + 4
    end
  end

  describe "current step" do
    setup [:with_campaign_subjects]

    test "infers calls' current steps from session data", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "no",
            "survey/3/symptom:123e4567-e89b-12d3-a456-426655440111" => "no",
            ".survey/3" => %{
              "step" => 2
            },
            ".survey/4" => %{
              "step" => 1
            }
          }
        }
      ]

      assert AidaBot.subject_answers(campaign, data) == %{
               subject.registration_identifier => %{
                 "language" => "es",
                 "answers" => %{
                   1 => %{
                     "current_step" => "thanks",
                     "symptoms" => %{
                       "123e4567-e89b-12d3-a456-426655440111" => false,
                       "123e4567-e89b-12d3-a456-426655440222" => true
                     }
                   },
                   3 => %{
                     "current_step" => "symptom:123e4567-e89b-12d3-a456-426655440222",
                     "symptoms" => %{"123e4567-e89b-12d3-a456-426655440111" => false}
                   },
                   4 => %{
                     "current_step" => "symptom:123e4567-e89b-12d3-a456-426655440111",
                     "symptoms" => %{}
                   }
                 }
               }
             }
    end

    test "should insert a call with it's current step", %{campaign: campaign, subject: subject} do
      known_subjects_answers = %{
        subject => %{
          "language" => "en",
          "answers" => %{
            1 => %{
              "current_step" => "thanks",
              "symptoms" => %{
                "123e4567-e89b-12d3-a456-426655440111" => false,
                "123e4567-e89b-12d3-a456-426655440222" => true
              }
            },
            4 => %{
              "current_step" => "symptom:123e4567-e89b-12d3-a456-426655440222",
              "symptoms" => %{"123e4567-e89b-12d3-a456-426655440111" => true}
            }
          }
        }
      }

      AidaBot.create_missing_calls_and_answers(known_subjects_answers, campaign)

      [first, second] = Repo.all(Call)

      assert (first.current_step == "thanks" and
                second.current_step == "symptom:123e4567-e89b-12d3-a456-426655440222") or
               (second.current_step == "thanks" and
                  first.current_step == "symptom:123e4567-e89b-12d3-a456-426655440222")
    end
  end

  describe "forward on any symptom" do
    setup do
      context = with_campaign_subjects(nil)
      campaign = Keyword.get(context, :campaign)
      subject = Keyword.get(context, :subject)
      campaign = Campaign.changeset(campaign, %{forwarding_condition: "any"}) |> Repo.update!
      {:ok, campaign: campaign, subject: subject}
    end

    test "doesn't have to forward", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "no",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "no"
          }
        }
      ]

      retrieve_mocked_campaign_data(campaign, data)

      assert Repo.one(Call).needs_to_be_forwarded == false
    end

    test "has to forward", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "no"
          }
        }
      ]

      retrieve_mocked_campaign_data(campaign, data)

      assert Repo.one(Call).needs_to_be_forwarded == true
    end
  end

  describe "forward on all symptoms" do
    setup do
      context = with_campaign_subjects(nil)
      campaign = Keyword.get(context, :campaign)
      subject = Keyword.get(context, :subject)
      campaign = Campaign.changeset(campaign, %{forwarding_condition: "all"}) |> Repo.update!
      {:ok, campaign: campaign, subject: subject}
    end

    test "doesn't have to forward", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "no"
          }
        }
      ]

      retrieve_mocked_campaign_data(campaign, data)

      assert Repo.one(Call).needs_to_be_forwarded == false
    end

    test "has to forward", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440111" => "yes"
          }
        }
      ]

      retrieve_mocked_campaign_data(campaign, data)

      assert Repo.one(Call).needs_to_be_forwarded == true
    end

    test "doesn't have to forward on ongoing session", %{campaign: campaign, subject: subject} do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "es",
            "survey/registration/registration_id" => subject.registration_identifier,
            "survey/1/symptom:123e4567-e89b-12d3-a456-426655440222" => "yes",
            ".survey/1" => %{
              "step" => 1
            }
          }
        }
      ]

      retrieve_mocked_campaign_data(campaign, data)

      assert Repo.one(Call).needs_to_be_forwarded == false
    end
  end

  describe "duplicated calls" do
    setup [:with_campaign_subjects, :with_subject_calls]

    test "should not create calls for unknown subjects", %{call: call} do
      {:ok, ignored} =
        build(
          :call,
          campaign: call.campaign,
          subject: call.subject,
          inserted_at: call.inserted_at
        )
        |> Repo.insert(on_conflict: :nothing)

      assert is_nil(ignored.id)
    end
  end

  describe "subject names" do
    setup [:with_campaign_subjects, :with_subject_calls]

    test "should update a subject's contact address with their full name if available", %{
      campaign: campaign,
      subject: subject
    } do
      data = [
        %{
          "id" => "aaaaaaaa-336c-4ad2-ba5c-b49676da20f6",
          "data" => %{
            "language" => "en",
            "survey/registration/registration_id" => subject.registration_identifier,
            "first_name" => "Guy",
            "last_name" => "Incognito"
          }
        }
      ]
      new_name = "Guy Incognito"

      assert (Subject |> Repo.get!(subject.id)).contact_address != new_name

      retrieve_mocked_campaign_data(campaign, data)

      assert (Subject |> Repo.get!(subject.id)).contact_address == new_name
    end
  end

  describe "publish" do
    test "should send the manifest to aida" do
      with_mock HTTPoison,
        post: fn _url, _body, _params ->
          {
            :ok,
            %HTTPoison.Response{
              body:
                %{
                  data: %{
                    id: "82f0c3dd-7313-4896-9797-f0479e236219",
                    manifest: "Stored Manifest",
                    temp: false
                  }
                }
                |> Poison.encode!()
            }
          }
        end do
        response =
          "THE MANIFEST"
          |> AidaBot.publish()

        assert response == %{
                 "id" => "82f0c3dd-7313-4896-9797-f0479e236219",
                 "manifest" => "Stored Manifest",
                 "temp" => false
               }

        assert called(
                 HTTPoison.post(
                   "http://aida-backend/api/bots",
                   %{bot: %{manifest: "THE MANIFEST"}} |> Poison.encode!(),
                   [{'Accept', 'application/json'}, {"Content-Type", "application/json"}]
                 )
               )
      end
    end

    test "should update the manifest" do
      with_mock HTTPoison,
        put: fn _url, _body, _params ->
          {
            :ok,
            %HTTPoison.Response{
              body:
                %{
                  data: %{
                    id: "e8762231-d624-4986-ac2d-b8a4d95f7226",
                    manifest: "Stored Manifest",
                    temp: false
                  }
                }
                |> Poison.encode!()
            }
          }
        end do
        response =
          "THE MANIFEST"
          |> AidaBot.update("e8762231-d624-4986-ac2d-b8a4d95f7226")

        assert response == %{
                 "id" => "e8762231-d624-4986-ac2d-b8a4d95f7226",
                 "manifest" => "Stored Manifest",
                 "temp" => false
               }

        assert called(
                 HTTPoison.put(
                   "http://aida-backend/api/bots/e8762231-d624-4986-ac2d-b8a4d95f7226",
                   %{bot: %{manifest: "THE MANIFEST"}} |> Poison.encode!(),
                   [{'Accept', 'application/json'}, {"Content-Type", "application/json"}]
                 )
               )
      end
    end
  end
end
