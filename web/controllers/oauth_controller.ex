defmodule ActiveMonitoring.OauthController do
  use ActiveMonitoring.Web, :controller

  def login(conn, params) do
    auth_params = %{
      client_id: Application.get_env(:guisso, :client_id),
      response_type: "code",
      scope: "openid email",
      redirect_uri: Application.get_env(:guisso, :redirect_uri),
      state: csrf_token(),
    }

    url = "https://accounts.google.com/o/oauth2/v2/auth?#{URI.encode_query(auth_params)}"

    redirect(conn, external: url)
  end

  def oauth_callback(conn, %{"code" => code}) do
    # TODO: verify csrf_token

    token_params = [
      code: code,
      client_id: Application.get_env(:guisso, :client_id),
      client_secret: Application.get_env(:guisso, :client_secret),
      redirect_uri: Application.get_env(:guisso, :redirect_uri),
      grant_type: "authorization_code"
    ]

    # TODO: use discovery endpoint
    case HTTPoison.post("https://www.googleapis.com/oauth2/v4/token", { :form, token_params }) do
      {:ok, response} ->
        case Poison.decode(response.body) do
          {:ok, %{ "id_token" => jwt }} ->
            [header, payload, secret] = String.split(jwt, ".")
            {:ok, payload_json} = Base.decode64(payload, padding: false)
            {:ok, parsed_jwt} = Poison.decode(payload_json)
            text conn, "Welcome #{parsed_jwt["email"]}!"
          # _error ->
          #   text conn, "Logged in!"
        end
      # _error ->
      #   render(conn, :error)
    end
  end


  defp csrf_token do
    # TODO: generate secure random token
    "foobar"
  end

end
