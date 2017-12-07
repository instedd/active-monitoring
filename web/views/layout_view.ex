defmodule ActiveMonitoring.LayoutView do
  use ActiveMonitoring.Web, :view

  def config(conn) do
    version = Application.get_env(:active_monitoring, :version)
    user_email = case conn.assigns[:current_user] do
      nil -> nil
      user -> user.email
    end

    client_config = %{
      version: version,
      user: user_email,
      logout_url: guisso_logout_url(conn),
      verboice: [Application.get_env(:active_monitoring, :verboice)] |> guisso_configs
    }

    {:ok, config_json} = client_config |> Poison.encode
    config_json
  end

  defp guisso_logout_url(conn) do
    guisso_settings = Application.get_env(:active_monitoring, :guisso)
    url_params = %{ after_sign_out_url: "#{url(conn)}#{Coherence.Config.logged_out_url("/")}" }
    "#{guisso_settings[:base_url]}/users/sign_out?#{URI.encode_query(url_params)}"
  end

  defp guisso_configs(app_env) do
    Enum.map(app_env, &guisso_config/1)
  end

  defp guisso_config(app_env) do
    %{
      baseUrl: app_env[:base_url],
      friendlyName: app_env[:friendly_name],
      guisso: %{
        baseUrl: app_env[:guisso][:base_url],
        clientId: app_env[:guisso][:client_id],
        appId: app_env[:guisso][:app_id]
      }
    }
  end

  def js_script_tag do
    if Mix.env == :prod do
      "<script src=\"/js/app.js\"></script>"
    else
      "<script src=\"http://localhost:4001/js/app.js\"></script>"
    end
  end

  def css_script_tag do
    if Mix.env == :prod do
      "<link rel=\"stylesheet\" href=\"/css/app.css\">"
    else
      "<link rel=\"stylesheet\" href=\"http://localhost:4001/css/app.css\">"
    end
  end

end
