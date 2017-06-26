defmodule ActiveMonitoring.CampaignTest do
  use ActiveMonitoring.ModelCase

  alias ActiveMonitoring.{Campaign}

  import ActiveMonitoring.Factory

  setup do
    [campaign: build(:campaign) |> with_audios]
  end

  test "generate steps from symptoms", context do
    assert ["language", "welcome", "symptom:id-fever", "symptom:id-rash", "forward", "educational", "thanks"] == Campaign.steps(context[:campaign])
  end

  test "returns audio for language topic", context do
    assert "id-language" == Campaign.audio_for(context[:campaign], "language", nil)
  end

  test "returns audio for symptom", context do
    assert "id-symptom:id-rash-en" == Campaign.audio_for(context[:campaign], "symptom:id-rash", "en")
  end

  test "returns nil for audio for missing language", context do
    assert nil == Campaign.audio_for(context[:campaign], "symptom:id-rash", "it")
  end

  test "returns nil for audio for missing topic", context do
    assert nil == Campaign.audio_for(context[:campaign], "symptom:id-notexists", "en")
  end
end
