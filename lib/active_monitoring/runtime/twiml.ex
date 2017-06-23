defmodule ActiveMonitoring.Runtime.TwiML do

  import XmlBuilder

  alias ActiveMonitoring.Router.Helpers

  def translate({:play, audio_uuid}, callback_url) do
    [ element(:Play, audio_url_for(audio_uuid)),
      redirect(callback_url) ]
        |> response
        |> generate
  end

  def translate({:gather, audio_uuid}, callback_url) do
    element(:Gather, %{method: "POST", action: callback_url}, [element(:Play, audio_url_for(audio_uuid))])
      |> response
      |> generate
  end

  def translate({:forward, audio_uuid}, callback_url) do
    throw :unimplemented
  end

  def translate({:hangup, audio_uuid}, _callback_url) do
    [ element(:Play, audio_url_for(audio_uuid)),
      hangup() ]
        |> response
        |> generate
  end

  defp audio_url_for(audio_uuid) do
    Helpers.audio_url(ActiveMonitoring.Endpoint, :show, audio_uuid)
  end

  defp redirect(url) do
    element(:Redirect, url)
  end

  defp hangup do
    element(:Hangup)
  end

  defp response(content) when is_list(content) do
    element(:Response, content)
  end

  defp response(content) do
    element(:Response, [content])
  end

end
