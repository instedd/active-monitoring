defmodule ActiveMonitoring.VerboiceCallbacksControllerTest do
  use ActiveMonitoring.ConnCase
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{Repo, Campaign, Runtime.Flow}

  describe "on call receive" do
    setup do
      owner = build(:user, email: "test@example.com") |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      Flow.handle_status(campaign.id, "abc123", "12345678", "")
      {:ok, campaign: campaign}
    end

    @tag :skip
    test "answers a verboice status call", %{conn: conn, campaign: campaign} do
      cs = Campaign.changeset(campaign, %{})
      Repo.update(Ecto.Changeset.put_change(cs, :started_at, Ecto.DateTime.utc()))
      conn = post(conn, verboice_callbacks_path(conn, :callback, campaign.id, CallSid: "abc123"))
      assert conn.status == 200
    end

    @tag :skip
    test "refuses a call if campaign hasn't begun", %{conn: conn, campaign: campaign} do
      conn = post conn, verboice_callbacks_path(conn, :callback, campaign.id, CallSid: "abc123")
      assert conn.resp_body == "<Hangup/>"
      assert conn.status == 503
    end
  end
end
