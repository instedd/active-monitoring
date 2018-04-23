defmodule ActiveMonitoring.CampaignsControllerTest do
  use ActiveMonitoring.ConnCase
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{Repo}

  setup %{conn: conn} do
    user = build(:user, email: "test@example.com") |> Repo.insert!
    other = build(:user, email: "other@example.com") |> Repo.insert!
    other_user_campaign = build(:campaign, user: other) |> Repo.insert!
    conn = conn
    |> assign(:current_user, user)
    {:ok, conn: conn, user: user, other: other, other_user_campaign: other_user_campaign}
  end

  describe "index" do
    test "is empty when there are no user campaigns", %{conn: conn} do
      response = conn |> get(campaigns_path(conn, :index)) |> json_response(200)
      assert response["data"] == []
    end

    test "shows only user campaigns", %{conn: conn, user: user, other_user_campaign: other_user_campaign} do
      a_campaign = build(:campaign, user: user) |> Repo.insert!
      other_campaign = build(:campaign, user: user) |> Repo.insert!

      response = conn |> get(campaigns_path(conn, :index)) |> json_response(200)
      mapped_data = Enum.map(response["data"], fn(camp) -> camp["id"] end)

      assert Enum.member? mapped_data, a_campaign.id
      assert Enum.member? mapped_data, other_campaign.id
      assert ! Enum.member? mapped_data, other_user_campaign.id
    end
  end

  describe "show" do
    setup [:with_user_campaign]

    test "a user campaign", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_path(conn, :show, campaign)) |> json_response(200)
      assert response["data"]["id"] == campaign.id
      assert response["data"]["name"] == campaign.name
    end

    test "unauthorized when trying to view another user's campaign", %{conn: conn, other_user_campaign: other_user_campaign} do
      assert_error_sent 403, fn ->
        conn |> get(campaigns_path(conn, :show, other_user_campaign))
      end
    end

    test "not found when trying to view a campaign that doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        conn |> get(campaigns_path(conn, :show, -1))
      end
    end
  end

  describe "manifest.json" do
    setup [:with_user_campaign]

    test "a user campaign manifest", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_manifest_path(conn, :manifest, campaign)) |> json_response(200)
      assert response["data"]["version"] == "1"
      assert response["data"]["languages"] == campaign.langs
    end

    test "unauthorized when trying to view another user's campaign manifest", %{conn: conn, other_user_campaign: other_user_campaign} do
      assert_error_sent 403, fn ->
        conn |> get(campaigns_manifest_path(conn, :manifest, other_user_campaign))
      end
    end

    test "not found when trying to view the manifest of a campaign that doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        conn |> get(campaigns_manifest_path(conn, :manifest, -1))
      end
    end
  end

  describe "update" do
    setup [:with_user_campaign]

    test "can update a user campaign", %{conn: conn, campaign: campaign} do
      new_campaign_name = "Another campaign name"
      assert campaign.name != new_campaign_name
      response = conn |> patch(campaigns_path(conn, :update, campaign), campaign: %{name: new_campaign_name}) |> json_response(200)
      assert response["data"]["id"] == campaign.id
      assert response["data"]["name"] == new_campaign_name
    end

    test "unauthorized when trying to update another user's campaign", %{conn: conn, other_user_campaign: other_user_campaign} do
      assert_error_sent 403, fn ->
        conn |> patch(campaigns_path(conn, :update, other_user_campaign), campaign: %{name: "Another campaign name"})
      end
    end

    test "not found when trying to update a campaign that doesn't exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        conn |> patch(campaigns_path(conn, :update, -1), campaign: %{name: "Another campaign name"})
      end
    end
  end

  describe "errors" do
    setup [:with_started_campaign]

    test "launch", %{conn: conn, campaign: campaign, user: user} do
      build(:campaign, user: user, channel: campaign.channel) |> Repo.insert!
      conn = conn |> put(campaigns_launch_path(conn, :launch, campaign))
      assert json_response(conn, 403) == %{"errors" => %{"channel" => "already in use"}}
    end
  end

  defp with_user_campaign %{user: user} do
    campaign = build(:campaign, user: user) |> Repo.insert!
    [campaign: campaign]
  end

  defp with_started_campaign %{user: user} do
    campaign = build(:campaign, user: user, channel: "a.channel", started_at: Ecto.DateTime.utc()) |> Repo.insert!
    [campaign: campaign]
  end
end
