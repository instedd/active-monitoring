defmodule ActiveMonitoring.AidaBot do
  alias ActiveMonitoring.Campaign

  def manifest(campaign) do
    languages =
      campaign.langs
      |> Enum.map(fn lang ->
        {lang, [lang]}
      end)
      |> Enum.into(%{})

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
          languages: languages,
          type: "language_detector"
        }
      ]
    }
    |> Poison.encode!()
  end
end
