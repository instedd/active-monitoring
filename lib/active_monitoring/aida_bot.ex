defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.Campaign

  def manifest(campaign) do
    %{
      "version": "1",
      "languages": campaign.langs,
      "front_desk": %{
        "greeting": %{
          "message": %{
            "en": campaign |> Campaign.welcome(%{mode: "chat", language: "en"}),
            "es": campaign |> Campaign.welcome(%{mode: "chat", language: "es"})
          }
        }
      }
    }
  end
end