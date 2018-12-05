defmodule ActiveMonitoring.PageView do
  use ActiveMonitoring.Web, :view

  def config_intercom(_conn) do
    ActiveMonitoring.Intercom.config_intercom()
  end
end
