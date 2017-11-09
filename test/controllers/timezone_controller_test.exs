defmodule ActiveMonitoring.TimezoneControllerTest do
  use ActiveMonitoring.ConnCase
  use ExUnit.Case
  import ActiveMonitoring.Factory

  setup %{conn: conn} do
    user = build(:user, email: "test@example.com") |> Repo.insert!
    conn = conn
    |> assign(:current_user, user)
    {:ok, conn: conn, user: user}
  end

  test "returns Timex timezones", %{conn: conn} do
    response = conn |> get(timezone_path(conn, :timezones)) |> json_response(200)
    assert response["data"] == Timex.timezones
  end
end
