defmodule ActiveMonitoring.ChannelsView do
  use ActiveMonitoring.Web, :view

  alias ActiveMonitoring.CampaignsView

  def render("index.json", %{channels: channels}) do
    rendered = channels |> Enum.map(fn(channel) ->
      render_one(channel)
    end)
    %{data: rendered}
  end

  defp render_one(channel) do
    %{
      id: channel.id,
      name: channel.name,
      active_campaign: channel.active_campaign && CampaignsView.render_one(channel.active_campaign)
    }
  end
end
