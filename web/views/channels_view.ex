defmodule ActiveMonitoring.ChannelsView do
  use ActiveMonitoring.Web, :view

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
      provider: channel.provider
    }
  end
end
