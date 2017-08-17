defmodule ActiveMonitoring.ChannelsView do
  use ActiveMonitoring.Web, :view

  def render("index.json", %{channels: channels}) do
    channels || []
  end
end
