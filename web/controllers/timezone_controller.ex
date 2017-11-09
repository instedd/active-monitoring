defmodule ActiveMonitoring.TimezoneController do
  use ActiveMonitoring.Web, :controller

  def timezones(conn, _) do
    timezones = Timex.timezones
    render(conn, "index.json", timezones: timezones)
  end
end
