defmodule ActiveMonitoring.AudioView do
  use ActiveMonitoring.Web, :view

  def render("show.json", %{audio: audio}) do
    %{data: render_one(audio, ActiveMonitoring.AudioView, "audio.json")}
  end

  def render("audio.json", %{audio: audio}) do
    audio
  end
end
