defmodule ActiveMonitoring.VerboiceCallbacksController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{Channel, Repo, Campaign}
  alias ActiveMonitoring.Runtime.{Flow, TwiML}
  alias ActiveMonitoring.Router.Helpers

  def callback(conn, params = %{"uuid" => uuid, "CallSid" => sid}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    campaign = Campaign |> Repo.get_by!(channel_id: channel.id)
    if campaign.started_at != nil do
      callback_url = Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, uuid)
      response = Flow.handle(channel.id, sid, params["Digits"])

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

  def status(conn, %{"uuid" => uuid, "From" => from, "CallSid" => sid, "CallStatus" => status}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    Flow.handle_status(channel.id, sid, from, status)
    send_resp(conn, :no_content, "")
  end
end
