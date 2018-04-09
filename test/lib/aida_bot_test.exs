defmodule ActiveMonitoring.AidaBotTest do
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{AidaBot, Campaign}

  setup do
    [campaign: build(:campaign)]
  end

  describe "manifest" do
    test "it should be a version 1 manifest", context do
      manifest = AidaBot.manifest context[:campaign]
      assert manifest.version == "1"
    end

    test "it takes languages from campaign", context do
      manifest = AidaBot.manifest context[:campaign]
      assert manifest.languages == ["en", "es"]
    end

    test "there is a greeting for each language", context do
      manifest =
        context[:campaign]
        |> with_chat_texts
        |> Campaign.with_welcome(%{mode: "chat", language: "en", value: "Welcome to the campaign!"})
        |> Campaign.with_welcome(%{mode: "chat", language: "es", value: "Bienvenidos a la campaña!"})
        |> AidaBot.manifest

      assert manifest.front_desk.greeting.message == %{
        "en": "Welcome to the campaign!",
        "es": "Bienvenidos a la campaña!"
      }
    end
  end
end
