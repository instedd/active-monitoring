defmodule ActiveMonitoring.AidaBotTest do
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{AidaBot, Campaign}

  setup do
    [campaign: build(:campaign)]
  end

  describe "manifest" do
    test "it should be a version 1 manifest", context do
      manifest = context[:campaign]
      |> AidaBot.manifest
      |> Poison.decode!
      assert manifest["version"] == "1"
    end

    test "it takes languages from campaign", context do
      manifest = context[:campaign]
      |> AidaBot.manifest
      |> Poison.decode!

      assert manifest["languages"] == ["en", "es"]
    end

    test "there is a greeting for each language", context do
      manifest =
        context[:campaign]
        |> Campaign.with_welcome(%{mode: "chat", language: "en", value: "Welcome to the campaign!"})
        |> Campaign.with_welcome(%{mode: "chat", language: "es", value: "Bienvenidos a la campaña!"})
        |> AidaBot.manifest
        |> Poison.decode!

      assert manifest["front_desk"]["greeting"]["message"] == %{
        "en" => "Welcome to the campaign!",
        "es" => "Bienvenidos a la campaña!"
      }
    end

    test "there is a language detector skill" do
      manifest =
        build(:campaign, %{langs: ["en", "es"]})
        |> Campaign.with_chat_text(%{topic: "language", value: "To chat in english say 'en'. Para hablar en español escribe 'es'"})
        |> AidaBot.manifest
        |> Poison.decode!

      assert manifest["skills"] == [
        %{
          "type" => "language_detector",
          "explanation" => "To chat in english say 'en'. Para hablar en español escribe 'es'",
          "languages" => %{
            "en" => ["en"],
            "es" => ["es"]
          }
        }
      ]
    end
  end
end
