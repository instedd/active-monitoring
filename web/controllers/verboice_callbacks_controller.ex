defmodule ActiveMonitoring.VerboiceCallbacksController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{Channel, Repo}
  alias ActiveMonitoring.Runtime.{Flow, TwiML}
  alias ActiveMonitoring.Router.Helpers

  def callback(conn, params = %{"uuid" => uuid, "CallSid" => sid}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    callback_url = Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, uuid)
    response = Flow.handle(channel.id, sid, params["Digits"])

    xml = response |> TwiML.build(callback_url)

    conn
      |> put_resp_content_type("text/xml")
      |> send_resp(200, xml)
  end

  def status(conn, %{"uuid" => uuid, "From" => from, "CallSid" => sid, "CallStatus" => status}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    c = Campaign |> Repo.get_by!(channel_id: channel.id)
    if c.started_at != nil do
      Flow.handle_status(channel.id, sid, from, status)
      send_resp(conn, :no_content, "")
    else
      send_resp(conn, 503, "")
    end
  end
end
