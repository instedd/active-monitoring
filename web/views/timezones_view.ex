defmodule ActiveMonitoring.TimezoneView do
  use ActiveMonitoring.Web, :view

  def render("index.json", %{timezones: timezones}) do
    %{data: timezones}
  end
end
