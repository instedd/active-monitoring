defmodule User.Helper do
  alias ActiveMonitoring.UnauthorizedError

  def current_user(conn) do
    case conn.assigns do
      %{current_user: user} -> user
      _ -> nil
    end
  end

  def authorize_campaign(campaign, conn) do
    if campaign.user_id != current_user(conn).id do
      raise UnauthorizedError, conn: conn
    end
    campaign
  end
end
