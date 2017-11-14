defmodule ActiveMonitoring.CallTest do
  use ActiveMonitoring.ModelCase

  alias ActiveMonitoring.{Call, Repo}

  import ActiveMonitoring.Factory
  require Logger

  setup do
    call = build(:call) |> Repo.insert!
    %{campaign: campaign} = call
    second_call = build(:call, campaign: campaign) |> Repo.insert!
    other_campaign = build(:campaign) |> Repo.insert!
    other_call = build(:call, campaign: other_campaign) |> Repo.insert!
    {:ok, call: call, second_call: second_call, campaign: campaign, other_call: other_call, other_campaign: other_campaign}
  end

  test "stats only count each campaign's calls", %{campaign: campaign, other_campaign: other_campaign} do
    assert Call.stats(campaign)[:today] == 2
    assert Call.stats(other_campaign)[:today] == 1
  end
end
