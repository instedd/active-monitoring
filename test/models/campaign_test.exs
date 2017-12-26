defmodule ActiveMonitoring.CampaignTest do
  use ActiveMonitoring.ModelCase

  alias ActiveMonitoring.{Campaign}
  alias Timex.Parse.DateTime.{Parser}

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

  describe "monitoring" do
    setup [:persist_campaign]

    test "campaign without subjects doesn't have any subject to contact today", %{campaign: campaign} do
      assert [] == Campaign.subjects_pending_check_in(campaign, [], Timex.now)
    end

    test "campaign with one pending subject has one subject to contact", %{campaign: campaign} do
      subject = build(:subject, campaign: campaign) |> Repo.insert!
      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject], Timex.now)

      assert length(subjects_to_contact) == 1
      assert Enum.at(subjects_to_contact, 0).id == subject.id
    end

    test "campaign with one subject who called in has no subjects to contact", %{campaign: campaign} do
      subject = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject, campaign: campaign, current_step: "thanks") |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject], Timex.now)

      assert length(subjects_to_contact) == 0
    end

    test "campaign with two subjects, only one called in, has one subject to contact", %{campaign: campaign} do
      subject_who_called = build(:subject, campaign: campaign) |> Repo.insert!
      other_subject = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject_who_called, campaign: campaign, current_step: "thanks") |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject_who_called, other_subject], Timex.now)

      assert length(subjects_to_contact) == 1
      assert Enum.at(subjects_to_contact, 0).id == other_subject.id
    end
  end

  defp datetime(datetime) do
    case Parser.parse(datetime, "{ISO:Extended:Z}") do
      {:ok, date} -> date
      _ -> nil
    end
  end

  describe "monitoring in a timezone behind UTC (Santiago)" do
    setup [:with_timezone_behind_utc, :persist_campaign]

    test "checking a call that was made on the same local day but different UTC day", %{campaign: campaign} do
      subject = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject, campaign: campaign, current_step: "thanks", updated_at: datetime("2017-02-15T22:00:00Z")) |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject], datetime("2017-02-16T02:00:00Z"))

      assert length(subjects_to_contact) == 0
    end

    test "checking a call that was made on different local days and different UTC day", %{campaign: campaign} do
      subject = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject, campaign: campaign, current_step: "thanks", updated_at: datetime("2017-02-15T22:00:00Z")) |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject], datetime("2017-02-16T05:00:00Z"))

      assert length(subjects_to_contact) == 1
      assert Enum.at(subjects_to_contact, 0).id == subject.id
    end
  end

  describe "monitoring in a timezone ahead of UTC (Nairobi)" do
    setup [:with_timezone_ahead_utc, :persist_campaign]

    test "checking a call that was made on different local days but same UTC day", %{campaign: campaign} do
      subject = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject, campaign: campaign, current_step: "thanks", updated_at: datetime("2017-02-15T19:00:00Z")) |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject], datetime("2017-02-15T21:00:00Z"))

      assert length(subjects_to_contact) == 1
      assert Enum.at(subjects_to_contact, 0).id == subject.id
    end

    test "checking a call that was made on the same local day and same UTC day", %{campaign: campaign} do
      subject_who_called = build(:subject, campaign: campaign) |> Repo.insert!
      build(:call, subject: subject_who_called, campaign: campaign, current_step: "thanks", updated_at: datetime("2017-02-15T22:00:00Z")) |> Repo.insert!

      subjects_to_contact = Campaign.subjects_pending_check_in(campaign, [subject_who_called], datetime("2017-02-15T23:00:00Z"))

      assert length(subjects_to_contact) == 0
    end
  end

  defp with_timezone_behind_utc %{campaign: campaign} do
    [campaign: %{campaign | timezone: "America/Santiago"}]
  end

  defp with_timezone_ahead_utc %{campaign: campaign} do
    [campaign: %{campaign | timezone: "Africa/Nairobi"}]
  end

  defp persist_campaign %{campaign: campaign} do
    campaign = Repo.insert!(campaign)
    [campaign: campaign]
  end

end
