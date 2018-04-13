defmodule ActiveMonitoring.CampaignsView do
  use ActiveMonitoring.Web, :view

  def render("index.json", %{campaigns: campaigns}) do
    rendered = campaigns |> Enum.map(fn(campaign) ->
      render_one(campaign)
    end)
    %{data: rendered}
  end


  def render("show.json", %{campaign: campaign, calls: calls, subjects: subjects}) do
    data = Map.merge(render_one(campaign), %{calls: calls})
    data = Map.merge(data, %{subjects: subjects})
    %{data: data}
  end

  def render("show.json", %{campaign: campaign}) do
    %{data: render_one(campaign)}
  end

  defp render_one(campaign) do
    %{
      id: campaign.id,
      name: campaign.name,
      mode: campaign.mode,
      symptoms: campaign.symptoms,
      forwarding_address: campaign.forwarding_address,
      forwarding_condition: campaign.forwarding_condition,
      messages: campaign.audios,
      audios: campaign.audios,
      chat_texts: campaign.chat_texts,
      langs: campaign.langs,
      additional_information: campaign.additional_information,
      started_at: campaign.started_at,
      monitor_duration: campaign.monitor_duration,
      timezone: campaign.timezone,
      channel: campaign.channel
    }
  end
end
