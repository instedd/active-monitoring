defmodule ActiveMonitoring.OAuthClientController do
  use ActiveMonitoring.Web, :controller

  plug :put_layout, false

  def index(conn, _params) do
    user = get_current_user(conn)
    auths = user |> assoc(:oauth_tokens) |> Repo.all

    render conn, "index.json", authorizations: auths
  end

  def delete(conn, %{"id" => provider, "base_url" => base_url}) do
    user = get_current_user(conn)

    user
    |> assoc(:oauth_tokens)
    |> Repo.get_by!(provider: provider, base_url: base_url)
    |> Repo.delete!

    send_resp(conn, :no_content, "")
  end

  def synchronize(conn, _params) do
    user = get_current_user(conn)

    user
    |> assoc(:oauth_tokens)
    |> Repo.all
    |> Enum.each(fn token ->
      provider = ActiveMonitoring.Channel.provider(token.provider)
      provider.sync_channels(user.id, token.base_url)
    end)

    send_resp(conn, :no_content, "")
  end

  def callback(conn, %{"code" => code, "state" => state}) do
    [provider_name, base_url] = String.split(state, "|", parts: 2)

    user = get_current_user(conn)
    token = user |> assoc(:oauth_tokens) |> Repo.get_by(provider: provider_name, base_url: base_url)

    error = if token == nil do
      provider = ActiveMonitoring.Channel.provider(provider_name)
      access_token = provider.oauth2_authorize(code, "#{url(conn)}#{conn.request_path}", base_url)

      if access_token.other_params && access_token.other_params["error"] do
        access_token.other_params["error_description"] || "Error connecting to provider: #{access_token.other_params["error"]}"
      else
        user
        |> build_assoc(:oauth_tokens, provider: provider_name, base_url: base_url)
        |> ActiveMonitoring.OAuthToken.from_access_token(access_token)
        |> Repo.insert!

        nil
      end
    end

    render conn, "callback.html", error: error
  end

  def callback(conn, _params) do
    render conn, "callback.html"
  end

  defp get_current_user(conn) do
    user = User.Helper.current_user(conn)
    Repo.get(ActiveMonitoring.User, user.id)
  end
end
