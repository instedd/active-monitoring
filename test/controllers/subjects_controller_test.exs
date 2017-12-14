defmodule ActiveMonitoring.SubjectsControllerTest do
  use ActiveMonitoring.ConnCase
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{Repo}

  setup %{conn: conn} do
    user = build(:user, email: "test@example.com") |> Repo.insert!
    campaign = build(:campaign, user: user) |> Repo.insert!

    other_user = build(:user, email: "other@example.com") |> Repo.insert!
    other_campaign = build(:campaign, user: other_user) |> Repo.insert!

    other_subject = build(:subject, campaign: other_campaign) |> Repo.insert!

    {:ok, conn: conn, user: user, campaign: campaign, other_campaign: other_campaign, other_subject: other_subject}
  end

  defp with_logged_in_user %{conn: conn, user: user} do
    conn = conn |> assign(:current_user, user)
    [conn: conn]
  end

  defp with_campaign_subjects %{campaign: campaign} do
    subject = build(:subject, campaign: campaign) |> Repo.insert!
    for _ <- 1..3, do: build(:subject, campaign: campaign) |> Repo.insert!
    [subject: subject]
  end

  defp with_many_subjects %{campaign: campaign} do
    for _ <- 1..100, do: build(:subject, campaign: campaign) |> Repo.insert!
    :ok
  end

  describe "campaign without subjects" do
    setup [:with_logged_in_user]

    test "shows an empty index", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert response["data"]["subjects"] == []
      assert response["meta"]["count"] == 0
    end
  end

  describe "campaign with subjects" do
    setup [:with_logged_in_user, :with_campaign_subjects]

    test "lists all subjects", %{conn: conn, campaign: campaign, subject: subject} do
      assert subject.registration_identifier != nil
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 4
      [subject1, subject2 | _] = response["data"]["subjects"]
      assert subject1["phoneNumber"] == subject.phone_number
      assert subject1["phoneNumber"] != subject2["phoneNumber"]
      assert subject1["registrationIdentifier"] == subject.registration_identifier
    end

    test "lists subjects by page size", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, limit: 2)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 2
      assert response["meta"]["count"] == 4
    end

    test "creates a subject", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert response["meta"]["count"] == 4

      phone_number = "4440000"
      registration_identifier = "12341234"

      response = conn
      |> post(campaigns_subjects_path(conn, :create, campaign), subject: %{phone_number: phone_number, registration_identifier: registration_identifier})
      |> json_response(201)

      assert response["data"]["id"]
      assert response["data"]["phoneNumber"] == phone_number
      assert response["data"]["campaignId"] == campaign.id
      assert response["data"]["registrationIdentifier"] == registration_identifier

      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert response["meta"]["count"] == 5
    end

    test "updates a subject", %{conn: conn, campaign: campaign, subject: subject} do
      phone_number = "4440000"
      registration_identifier = "12341234"
      assert subject.phone_number != phone_number
      assert subject.registration_identifier != registration_identifier

      response = conn
      |> patch(campaigns_subjects_path(conn, :update, campaign, subject), subject: %{phone_number: phone_number, registration_identifier: registration_identifier})
      |> json_response(200)

      assert response["data"]["id"] == subject.id
      assert response["data"]["phoneNumber"] == phone_number
      assert response["data"]["registrationIdentifier"] == registration_identifier
      assert response["data"]["campaignId"] == campaign.id
    end
  end

  describe "pagination with too many subjects" do
    setup [:with_logged_in_user, :with_many_subjects]

    test "lists subjects by page size when there are too many subjects", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] > 50
    end

    test "lists subjects by maximum page size when asked for more", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, limit: 100)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] > 50
    end

    test "lists second page of subjects", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      [first_subject | _ ] = response["data"]["subjects"]
      first_subject_id = first_subject["id"]

      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, page: 2)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] == 100
      require Logger
      second_page_subject_ids = Enum.map response["data"]["subjects"], fn(subject) -> subject["id"] end
      assert not(first_subject_id in second_page_subject_ids)
    end
  end

  describe "access control" do
    setup [:with_logged_in_user]

    test "doesn't allow to index another user's campaign subjects", %{conn: conn, other_campaign: other_campaign} do
      assert_error_sent 403, fn ->
        conn |> get(campaigns_subjects_path(conn, :index, other_campaign))
      end
    end

    test "not found when trying to list a campaign that doesn't exist subjects", %{conn: conn} do
      assert_error_sent 404, fn ->
        conn |> get(campaigns_subjects_path(conn, :index, -1))
      end
    end

    test "doesn't allow to create another user's campaign subject", %{conn: conn, other_campaign: other_campaign} do
      assert_error_sent 403, fn ->
        conn |> post(campaigns_subjects_path(conn, :create, other_campaign), subject: %{phone_number: "4444333221"})
      end
    end

    test "doesn't allow to update another user's campaign subject", %{conn: conn, other_campaign: other_campaign, other_subject: other_subject} do
      assert_error_sent 403, fn ->
        conn |> patch(campaigns_subjects_path(conn, :update, other_campaign, other_subject), subject: %{phone_number: "4444333221"})
      end
    end
  end
end
