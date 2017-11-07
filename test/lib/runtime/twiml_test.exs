defmodule ActiveMonitoring.Runtime.TwimlTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{TwiML}

  describe "build" do

    test "it should build a play step" do
      xml = TwiML.build({:play, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Redirect>CALLBACK_URL</Redirect>\n</Response>" == xml
    end

    test "it should build a gather step" do
      xml = TwiML.build({:gather, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Gather action=\"CALLBACK_URL\" method=\"POST\">\n\t\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t</Gather>\n</Response>" == xml
    end

    test "it should build a forward step" do
      xml = TwiML.build({:forward, %{audio: "AUDIO_UUID", number: "5550000"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Dial>5550000</Dial>\n\t<Redirect>CALLBACK_URL</Redirect>\n</Response>" == xml
    end

    test "it should build a hangup step" do
      xml = TwiML.build({:hangup, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Hangup/>\n</Response>" == xml
    end

  end
end
