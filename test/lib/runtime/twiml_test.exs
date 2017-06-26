defmodule ActiveMonitoring.Runtime.TwimlTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{TwiML}

  describe "translate" do

    test "it should translate a play step" do
      xml = TwiML.translate({:play, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Redirect>CALLBACK_URL</Redirect>\n</Response>" == xml
    end

    test "it should translate a gather step" do
      xml = TwiML.translate({:gather, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Gather action=\"CALLBACK_URL\" method=\"POST\">\n\t\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t</Gather>\n</Response>" == xml
    end

    test "it should translate a forward step" do
      xml = TwiML.translate({:forward, %{audio: "AUDIO_UUID", number: "5550000"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Dial>5550000</Dial>\n</Response>" == xml
    end

    test "it should translate a hangup step" do
      xml = TwiML.translate({:hangup, %{audio: "AUDIO_UUID"}}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Hangup/>\n</Response>" == xml
    end

  end
end
