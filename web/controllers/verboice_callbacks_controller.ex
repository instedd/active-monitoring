defmodule ActiveMonitoring.VerboiceCallbacksController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.{Channel, Repo}
  alias ActiveMonitoring.Runtime.{Flow, TwiML}
  alias ActiveMonitoring.Router.Helpers

  def callback(conn, params = %{"uuid" => uuid, "CallSid" => sid}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    callback_url = Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, uuid)
    {:ok, response} = Flow.handle(channel.id, sid, params["Digits"])

    IO.inspect(response)

    xml = response |> TwiML.translate(callback_url)

    IO.inspect(xml)

    conn
      |> put_resp_content_type("text/xml")
      |> send_resp(200, xml)
  end

  def status(conn, %{"uuid" => uuid, "From" => from, "CallSid" => sid, "CallStatus" => status}) do
    channel = Channel |> Repo.get_by!(uuid: uuid)
    Flow.handle_status(channel.id, sid, from, status)
    send_resp(conn, :no_content, "")
  end
end
