defmodule Coherence.LayoutView do
  use ActiveMonitoring.Coherence.Web, :view
  
  def config_intercom(_conn) do
    ActiveMonitoring.Intercom.config_intercom()
  end
end
