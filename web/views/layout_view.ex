defmodule ActiveMonitoring.LayoutView do
  use ActiveMonitoring.Web, :view

  def js_script_tag do
    if Mix.env == :prod do
      "<script src=\"/js/app.js\"></script>"
    else
      "<script src=\"http://localhost:4001/js/app.js\"></script>"
    end
  end

end
