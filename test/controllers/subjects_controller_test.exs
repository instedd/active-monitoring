defmodule ActiveMonitoring.SubjectsControllerTest do
  use ActiveMonitoring.ConnCase
  use ExUnit.Case
  import ActiveMonitoring.Factory

  alias ActiveMonitoring.{Repo}

  setup %{conn: conn} do
    user = build(:user, email: "test@example.com") |> Repo.insert!
    campaign = build(:campaign, user: user, monitor_duration: 30) |> Repo.insert!

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
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 4
      subj = Enum.find(response["data"]["subjects"], fn(sub) -> sub["registrationIdentifier"] == subject.registration_identifier end)
      assert subj
      assert subj["contactAddress"] == subject.contact_address
    end

    test "subjects csv export", %{conn: conn, campaign: campaign, subject: subject} do
      conn = conn |> get(campaigns_subjects_export_csv_path(conn, :export_csv, campaign))
      csv = conn |> response(200)
      assert get_resp_header(conn, "content-disposition") == ["attachment; filename=\"export_#{campaign.name}_subjects.csv\""]
      assert get_resp_header(conn, "content-type") == ["text/csv; charset=utf-8"]
      [header, line1 | _] = csv |> String.split("\r\n")
      assert header == "ID,Contact Address,Enroll date,First Call Date,Last Call Date,Last Successful Call,Active Case"
      assert line1 == "#{subject.registration_identifier},#{subject.contact_address},#{subject.inserted_at},,,,true"
    end

    test "lists subjects by page size", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, limit: 2)) |> json_response(200)
      assert length(response["data"]["subjects"]) == 2
      assert response["meta"]["count"] == 4
    end

    test "creates a subject", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert response["meta"]["count"] == 4

      contact_address = "4440000"
      registration_identifier = "12341234"

      response = conn
      |> post(campaigns_subjects_path(conn, :create, campaign), subject: %{contact_address: contact_address, registration_identifier: registration_identifier})
      |> json_response(201)

      assert response["data"]["id"]
      assert response["data"]["contactAddress"] == contact_address
      assert response["data"]["campaignId"] == campaign.id
      assert response["data"]["registrationIdentifier"] == registration_identifier

      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      assert response["meta"]["count"] == 5
    end

    test "updates a subject", %{conn: conn, campaign: campaign, subject: subject} do
      contact_address = "4440000"
      registration_identifier = "12341234"
      assert subject.contact_address != contact_address
      assert subject.registration_identifier != registration_identifier

      response = conn
      |> patch(campaigns_subjects_path(conn, :update, campaign, subject), subject: %{contact_address: contact_address, registration_identifier: registration_identifier})
      |> json_response(200)

      assert response["data"]["id"] == subject.id
      assert response["data"]["contactAddress"] == contact_address
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

    test "lists subjects by maximum page size when asked for invalid limit", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, limit: "INVALID")) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] > 50
    end

    test "lists second page of subjects", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      [first_subject | _ ] = response["data"]["subjects"]
      first_subject_id = first_subject["id"]

      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, page: "2")) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] == 100
      second_page_subject_ids = Enum.map response["data"]["subjects"], fn(subject) -> subject["id"] end
      assert not(first_subject_id in second_page_subject_ids)
    end

    test "list first page of subjects when asked for invalid page", %{conn: conn, campaign: campaign} do
      response = conn |> get(campaigns_subjects_path(conn, :index, campaign)) |> json_response(200)
      [first_subject | _ ] = response["data"]["subjects"]
      first_subject_id = first_subject["id"]

      response = conn |> get(campaigns_subjects_path(conn, :index, campaign, page: "INVALID")) |> json_response(200)
      assert length(response["data"]["subjects"]) == 50
      assert response["meta"]["count"] == 100
      first_page_subject_ids = Enum.map response["data"]["subjects"], fn(subject) -> subject["id"] end
      assert first_subject_id in first_page_subject_ids
    end
  end

  describe "access control" do
    setup [:with_logged_in_user]

    test "doesn't allow to index another user's campaign subjects", %{conn: conn, other_campaign: other_campaign} do
      assert_error_sent 403, fn ->
        conn |> get(campaigns_subjects_path(conn, :index, other_campaign))
      end
    end

    test "doesn't allow to export another user's campaign subjects", %{conn: conn, other_campaign: other_campaign} do
      assert_error_sent 403, fn ->
        conn |> get(campaigns_subjects_export_csv_path(conn, :export_csv, other_campaign))
      end
    end

    test "not found when trying to list a campaign that doesn't exist subjects", %{conn: conn} do
      assert_error_sent 404, fn ->
        conn |> get(campaigns_subjects_path(conn, :index, -1))
      end
    end

    test "doesn't allow to create another user's campaign subject", %{conn: conn, other_campaign: other_campaign} do
      assert_error_sent 403, fn ->
        conn |> post(campaigns_subjects_path(conn, :create, other_campaign), subject: %{contact_address: "4444333221"})
      end
    end

    test "doesn't allow to update another user's campaign subject", %{conn: conn, other_campaign: other_campaign, other_subject: other_subject} do
      assert_error_sent 403, fn ->
        conn |> patch(campaigns_subjects_path(conn, :update, other_campaign, other_subject), subject: %{contact_address: "4444333221"})
      end
    end
  end
end
