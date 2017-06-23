defmodule ActiveMonitoring.Runtime.TwimlTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{TwiML}
  alias Ecto.Query

  describe "translate" do

    test "it should translate a play step" do
      xml = TwiML.translate({:play, "AUDIO_UUID"}, "CALLBACK_URL")
      assert "<Response>\n\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t<Redirect>CALLBACK_URL</Redirect>\n</Response>" == xml
    end

    test "it should translate a gather step" do
      xml = TwiML.translate({:gather, "AUDIO_UUID"}, "CALLBACK_URL")
      assert "<Response>\n\t<Gather action=\"CALLBACK_URL\" method=\"POST\">\n\t\t<Play>http://test.example.com/api/v1/audios/AUDIO_UUID</Play>\n\t</Gather>\n</Response>" == xml
    end

  end
end
