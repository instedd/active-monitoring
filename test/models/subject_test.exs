defmodule ActiveMonitoring.SubjectTest do
  use ActiveMonitoring.ModelCase

  alias ActiveMonitoring.{Subject, Call}
  alias Timex.Parse.DateTime.{Parser}

  import ActiveMonitoring.Factory

  setup do
    campaign = build(:campaign) |> Repo.insert!
    subject = build(:subject, campaign: campaign) |> Repo.insert!
    %{campaign: campaign, subject: subject}
  end

  test "after a successful call last call date and last successful call date match", %{subject: subject, campaign: campaign} do
    call = build(:call, subject: subject, campaign: campaign, current_step: "language", inserted_at: Timex.shift(Timex.now, minutes: -3)) |> Repo.insert!
    Call.changeset(call, %{current_step: "thanks"}) |> Repo.update!
    assert Subject.last_call_date(subject) == Subject.last_successful_call_date(subject)
  end
end
