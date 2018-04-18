defmodule ActiveMonitoring.AidaBotTest do
  use ActiveMonitoring.ModelCase
  use Timex
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{AidaBot, Campaign}

  setup do
    [campaign: insert(:campaign)]
  end

  describe "manifest" do
    test "it should be a version 1 manifest", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()
        |> Poison.decode!()

      assert manifest["version"] == "1"
    end

    test "it takes languages from campaign", context do
      manifest =
        context[:campaign]
        |> AidaBot.manifest()
        |> Poison.decode!()

      assert manifest["languages"] == ["en", "es"]
    end


    test "there is a greeting for each language", context do
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
        |> Poison.decode!()

      assert manifest["front_desk"]["greeting"]["message"] == %{
        "en" => "Welcome to the campaign!",
        "es" => "Bienvenidos a la campaña!"
      }
    end

    test "there is a language detector skill" do
      manifest =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{topic: "language", value: "To chat in english say 'en'. Para hablar en español escribe 'es'"})
        |> AidaBot.manifest
        |> Poison.decode!

      assert manifest["skills"] |> Enum.fetch(0) == {:ok, %{
        "type" => "language_detector",
        "explanation" => "To chat in english say 'en'. Para hablar en español escribe 'es'",
        "languages" => %{
          "en" => ["en"],
          "es" => ["es"]
        }
      }}
    end

    test "it should have a survey with a text question to ask for the registration identifier" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "en",
          value: "Please tell me your Registration Id"
        })
        |> Campaign.with_chat_text(%{
          topic: "registration",
          language: "es",
          value: "Por favor dígame su número de registro"
        })

      manifest =
        campaign
        |> AidaBot.manifest
        |> Poison.decode!

      assert manifest["skills"] |> Enum.fetch(1) == {:ok, %{
        "type" => "survey",
        "id" => "registration",
        "name" => campaign.name,
        "keywords" => %{
          "en" => ["registration"],
          "es" => ["registration"]
        },
        "questions" => [
          %{
            "type" => "text",
            "name" => "registration_id",
            "message" => %{
              "en" => "Please tell me your Registration Id",
              "es" => "Por favor dígame su número de registro"
            }
          }
        ]
      }}
    end

    test "it should have a survey with a question for every symptom without subjects" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-fever",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-fever",
          language: "es",
          value: "¿Tiene usted fiebre?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-rash",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-rash",
          language: "es",
          value: "¿Tiene alguna erupción?"
        })


      manifest =
        campaign
        |> AidaBot.manifest
        |> Poison.decode!

      assert {:ok, %{
        "type" => "survey",
        "id" => "survey",
        "name" => "Campaign",
        "schedule" => schedule,
        "relevant" => nil,
        "questions" => [
          %{
            "type" => "select_one",
            "choices" => "yes_no",
            "name" => "symptom:id-fever",
            "message" => %{
              "en" => "Do you have fever?",
              "es" => "¿Tiene usted fiebre?"
            }
          },
          %{
            "type" => "select_one",
            "choices" => "yes_no",
            "name" => "symptom:id-rash",
            "message" => %{
              "en" => "Do you have rash?",
              "es" => "¿Tiene alguna erupción?"
            }
          }
        ],
        "choice_lists" => [
          %{
            "name" => "yes_no",
            "choices" => [
              %{
                "name" => "yes",
                "labels" => %{
                  "en" => ["yes"],
                  "es" => ["yes"]
                }
              },
              %{
                "name" => "no",
                "labels" => %{
                  "en" => ["no"],
                  "es" => ["no"]
                }
              }
            ]
          }
        ]
      }} = manifest["skills"] |> Enum.fetch(2)

      {:ok, schedule_date_time, _} = DateTime.from_iso8601(schedule)
      assert schedule_date_time in Interval.new(from: Timex.shift(DateTime.utc_now(), seconds: -5), until: Timex.shift(DateTime.utc_now(), seconds: 5), step: [seconds: 1])
    end

    test "it should have a survey with a question for every symptom with subjects" do
      campaign =
        insert(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-fever",
          language: "en",
          value: "Do you have fever?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-fever",
          language: "es",
          value: "¿Tiene usted fiebre?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-rash",
          language: "en",
          value: "Do you have rash?"
        })
        |> Campaign.with_chat_text(%{
          topic: "symptom:id-rash",
          language: "es",
          value: "¿Tiene alguna erupción?"
        })

      subject1 = insert(:subject, campaign: campaign)
      subject2 = insert(:subject, campaign: campaign)

      relevance = "${registration_id} == #{subject1.registration_identifier} || ${registration_id} == #{subject2.registration_identifier}"

      manifest =
        campaign
        # |> Repo.get!(campaign.id)
        # |> Repo.preload(:subjects)
        |> AidaBot.manifest()
        |> Poison.decode!()

      assert {:ok, %{
        "type" => "survey",
        "id" => "survey",
        "name" => "Campaign",
        "schedule" => schedule,
        "relevant" => ^relevance,
        "questions" => [
          %{
            "type" => "select_one",
            "choices" => "yes_no",
            "name" => "symptom:id-fever",
            "message" => %{
              "en" => "Do you have fever?",
              "es" => "¿Tiene usted fiebre?"
            }
          },
          %{
            "type" => "select_one",
            "choices" => "yes_no",
            "name" => "symptom:id-rash",
            "message" => %{
              "en" => "Do you have rash?",
              "es" => "¿Tiene alguna erupción?"
            }
          }
        ],
        "choice_lists" => [
          %{
            "name" => "yes_no",
            "choices" => [
              %{
                "name" => "yes",
                "labels" => %{
                  "en" => ["yes"],
                  "es" => ["yes"]
                }
              },
              %{
                "name" => "no",
                "labels" => %{
                  "en" => ["no"],
                  "es" => ["no"]
                }
              }
            ]
          }
        ]
      }} = manifest["skills"] |> Enum.fetch(2)

      {:ok, schedule_date_time, _} = DateTime.from_iso8601(schedule)
      assert schedule_date_time in Interval.new(from: Timex.shift(DateTime.utc_now(), seconds: -5), until: Timex.shift(DateTime.utc_now(), seconds: 5), step: [seconds: 1])


      # %{
      #   "language": "en",
      #   "registration/registration_id": "12345",
      #   "symptom:famine": "yes"
      #   ".survey": %{"step" : 1}
      # }
    end
  end
end
