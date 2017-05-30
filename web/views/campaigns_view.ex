defmodule ActiveMonitoring.CampaignsView do
  use ActiveMonitoring.Web, :view

  def render("index.json", %{campaigns: campaigns}) do
    rendered = campaigns |> Enum.map(fn(campaign) ->
      render_one(campaign)
    end)
    %{data: rendered}
  end

  defp render_one(campaign) do
    %{
      id: campaign.id,
      name: campaign.name
    }
  end
end
