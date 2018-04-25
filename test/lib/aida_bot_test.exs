defmodule ActiveMonitoring.AidaBotTest do
  use ActiveMonitoring.ModelCase
  use Timex
  import ActiveMonitoring.Factory
  import Mock

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

    test "there is no language detector skill if the campaign has only one language" do
      manifest =
        insert(:campaign, %{langs: ["en"]})
        |> Campaign.with_chat_text(%{topic: "language", value: "To chat in english say 'en'. Para hablar en español escribe 'es'"})
        |> AidaBot.manifest
        |> Poison.decode!

      assert manifest["skills"] |> Enum.count() == 1

      {:ok, survey}= manifest["skills"] |> Enum.fetch(0)

      assert survey["id"] == "registration"
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

    test "it shouldn't have a survey without subjects" do
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

      assert manifest["skills"] |> Enum.count == 2
    end

    test "surveys should have a question for every symptom" do
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
        |> AidaBot.manifest(%{1 => [subject1, subject2]})
        |> Poison.decode!()

      assert {:ok, %{
        "type" => "survey",
        "id" => "1",
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
    end

    test "should have one survey per monitor duration day if there is at least one subject for that day" do
        campaign =
        insert(:campaign, %{langs: ["en", "es"], monitor_duration: 3})
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

      subject3 = insert(:subject, campaign: campaign)

      relevance1 = "${registration_id} == #{subject1.registration_identifier} || ${registration_id} == #{subject2.registration_identifier}"

      relevance3 = "${registration_id} == #{subject3.registration_identifier}"

      manifest =
        campaign
        |> AidaBot.manifest(%{1 => [subject1, subject2], 3 => [subject3]})
        |> Poison.decode!()

      assert manifest["skills"] |> Enum.count == 4

      assert {:ok, %{
        "type" => "survey",
        "id" => "1",
        "name" => "Campaign",
        "schedule" => schedule,
        "relevant" => ^relevance1,
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

      assert {:ok, %{
        "type" => "survey",
        "id" => "3",
        "name" => "Campaign",
        "schedule" => schedule,
        "relevant" => ^relevance3,
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
      }} = manifest["skills"] |> Enum.fetch(3)

      {:ok, schedule_date_time, _} = DateTime.from_iso8601(schedule)
      assert schedule_date_time in Interval.new(from: Timex.shift(DateTime.utc_now(), seconds: -5), until: Timex.shift(DateTime.utc_now(), seconds: 5), step: [seconds: 1])
    end
  end

  describe "publish" do
    test "should send the manifest to aida" do
      with_mock HTTPoison, [post: fn(_url, _body) -> "ok" end] do
        "THE MANIFEST"
        |> AidaBot.publish()

        assert called HTTPoison.post("http://aida-backend/api/bots", "THE MANIFEST")
      end
    end
  end
end
