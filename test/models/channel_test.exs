defmodule ActiveMonitoring.ChannelTest do
  use ActiveMonitoring.ModelCase

  alias ActiveMonitoring.{Channel, Campaign}
  alias Ecto.Query

  import ActiveMonitoring.Factory

  setup do
    %{ channel: (build(:channel) |> Repo.insert!) }
  end

  describe "active campaign" do

    test "it should handle no associated campaign", %{channel: channel} do
      campaign = build(:campaign) |> Repo.insert!
      channel = Channel |> Channel.with_active_campaign |> Repo.one!
      assert is_nil(channel.active_campaign)
    end

    test "it should not retrieve campaign if not started", %{channel: channel} do
      campaign = build(:campaign, channel: channel) |> Repo.insert!
      channel = Channel |> Channel.with_active_campaign |> Repo.one!
      assert is_nil(channel.active_campaign)
    end

    test "it should not retrieve campaign if ended", %{channel: channel} do
      campaign = build(:campaign, channel: channel, started_at: Ecto.DateTime.utc, ended_at: Ecto.DateTime.utc) |> Repo.insert!
      channel = Channel |> Channel.with_active_campaign |> Repo.one!
      assert is_nil(channel.active_campaign)
    end

    test "it should retrieve campaign if active", %{channel: channel} do
      campaign = build(:campaign, channel: channel, started_at: Ecto.DateTime.utc) |> Repo.insert!
      channel = Channel |> Channel.with_active_campaign |> Repo.one!
      assert campaign.id == channel.active_campaign.id
    end

  end

end
