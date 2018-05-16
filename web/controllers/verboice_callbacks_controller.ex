defmodule ActiveMonitoring.VerboiceCallbacksController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{Repo, Campaign}
  alias ActiveMonitoring.Runtime.{Flow, TwiML}
  alias ActiveMonitoring.Router.Helpers

  def callback(conn, params = %{"campaign" => campaign_id, "CallSid" => sid}) do
    campaign = Campaign |> Repo.get!(campaign_id)
    if campaign.started_at != nil do
      callback_url = Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, campaign_id)
      response = Flow.handle(campaign_id, sid, params["Digits"])

      xml = response |> TwiML.build(callback_url)

      conn
        |> put_resp_content_type("text/xml")
        |> send_resp(200, xml)
    else
      xml = TwiML.build(:hangup)
      conn
        |> put_resp_content_type("text/xml")
        |> send_resp(503, xml)
    end
  end

  def status(conn, %{"campaign" => campaign_id, "From" => from, "CallSid" => sid, "CallStatus" => status}) do
    Flow.handle_status(campaign_id, sid, from, status)
    send_resp(conn, :no_content, "")
  end
end
