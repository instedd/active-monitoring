defmodule ActiveMonitoring.Runtime.TwiML do

  import XmlBuilder

  alias ActiveMonitoring.Router.Helpers

  def build({:play, %{audio: audio_uuid}}, callback_url) do
    [ play(audio_uuid),
      redirect(callback_url) ]
        |> response
        |> generate
  end

  def build({:gather, %{audio: audio_uuid}}, callback_url) do
    gather(callback_url, [ play(audio_uuid) ])
      |> response
      |> generate
  end

  def build({:forward, %{audio: audio_uuid, number: number}}, callback_url) do
    [ play(audio_uuid),
      dial(number),
      redirect(callback_url) ]
        |> response
        |> generate
  end

  def build({:hangup, %{audio: audio_uuid}}, _callback_url) do
    [ play(audio_uuid),
      hangup() ]
        |> response
        |> generate
  end

  def build(:hangup) do
    [ hangup() ]
    |> generate
  end

  defp play(audio_uuid) do
    element(:Play, audio_url_for(audio_uuid))
  end

  defp gather(callback_url, children) do
    element(:Gather, %{method: "POST", action: callback_url}, children)
  end

  defp dial(number) do
    element(:Dial, number)
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

  defp audio_url_for(audio_uuid) do
    Helpers.audio_url(ActiveMonitoring.Endpoint, :show, audio_uuid)
  end

end
