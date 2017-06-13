defmodule ActiveMonitoring.CampaignsView do
  use ActiveMonitoring.Web, :view

  def render("index.json", %{campaigns: campaigns}) do
    rendered = campaigns |> Enum.map(fn(campaign) ->
      render_one(campaign)
    end)
    %{data: rendered}
  end

  def render("show.json", %{campaign: campaign}) do
    %{data: render_one(campaign)}
  end


  defp render_one(campaign) do
    %{
      id: campaign.id,
      name: campaign.name,
      symptoms: campaign.symptoms,
      forwarding_number: campaign.forwarding_number,
      forwarding_condition: campaign.forwarding_condition
    }
  end
end
