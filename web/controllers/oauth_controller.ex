defmodule ActiveMonitoring.OauthController do
  use ActiveMonitoring.Web, :controller

  def login(conn, params) do
    conn = set_app_client_id(conn)
    csrf_token = generate_csrf_token(conn)

    auth_params = %{
      client_id: Application.get_env(:guisso, :client_id),
      response_type: "code",
      scope: "openid email",
      redirect_uri: Application.get_env(:guisso, :redirect_uri),
      state: csrf_token,
    }

    url = "https://accounts.google.com/o/oauth2/v2/auth?#{URI.encode_query(auth_params)}"

    redirect(conn, external: url)
  end

  def oauth_callback(conn, %{"code" => code, "state" => state}) do
    case verify_csrf_token(conn, state) do
      :ok ->
        token_params = [
          code: code,
          client_id: Application.get_env(:guisso, :client_id),
          client_secret: Application.get_env(:guisso, :client_secret),
          redirect_uri: Application.get_env(:guisso, :redirect_uri),
          grant_type: "authorization_code"
        ]

        case HTTPoison.post("https://www.googleapis.com/oauth2/v4/token", { :form, token_params }) do
          {:ok, response} ->
            {:ok, %{ "id_token" => jwt }} = Poison.decode(response.body)

            [header, payload, secret] = String.split(jwt, ".")
            {:ok, payload_json} = Base.decode64(payload, padding: false)
            {:ok, parsed_jwt} = Poison.decode(payload_json)

            text conn, "Welcome #{parsed_jwt["email"]}!"

          _error ->
            text conn, "An error occurred while logging you in."
        end
      { :error, cause } ->
        text conn, "An error occurred while logging you in."
    end
  end

  defp get_app_client_id(conn) do
    get_session(conn, :client_id)
  end

  defp set_app_client_id(conn) do
    client_id = :crypto.strong_rand_bytes(10) |> Base.encode64()
    put_session(conn, :client_id, client_id)
  end

  defp generate_csrf_token(conn) do
    client_id = get_app_client_id(conn)
    expiration = :os.system_time(:seconds) + 60 * 5
    signature = sign_csrf_token(client_id, expiration)

    "#{client_id}///#{expiration}///#{signature}"
  end

  def sign_csrf_token(client_id, expiration) do
    data = "#{client_id}///#{expiration}"
    secret = Application.get_env(:active_monitoring, ActiveMonitoring.Endpoint)[:secret_key_base]

    :crypto.hmac(:sha256, secret, data) |> Base.encode64()
  end

  def verify_csrf_token(conn, state) do
    current_time = :os.system_time(:seconds)
    expected_client_id = get_app_client_id(conn)

    case String.split(state, "///") do
      [^expected_client_id, expiration, signature] ->
        case String.to_integer(expiration) do
          num when num > current_time ->
            case sign_csrf_token(expected_client_id, expiration) do
              ^signature ->
                :ok
              _ ->
                {:error, :signature}
            end
          _ ->
            {:error, :expired}
        end
      _ ->
        {:error, :invalid_client}
    end
  end

end
