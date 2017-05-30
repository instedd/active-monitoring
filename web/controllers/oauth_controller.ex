defmodule ActiveMonitoring.OauthController do
  use ActiveMonitoring.Web, :controller

  def login(conn, _params) do
    guisso_settings = Application.get_env(:active_monitoring, :guisso)
    conn = set_app_client_id(conn)
    csrf_token = generate_csrf_token(conn)

    auth_params = %{
      client_id: guisso_settings[:client_id],
      response_type: "code",
      scope: "openid email",
      redirect_uri: guisso_settings[:redirect_uri],
      state: csrf_token,
    }

    url = "#{guisso_settings[:auth_url]}?#{URI.encode_query(auth_params)}"

    redirect(conn, external: url)
  end

  def oauth_callback(conn, %{"code" => code, "state" => state}) do
    guisso_settings = Application.get_env(:active_monitoring, :guisso)

    case verify_csrf_token(conn, state) do
      :ok ->
        token_params = [
          code: code,
          client_id: guisso_settings[:client_id],
          client_secret: guisso_settings[:client_secret],
          redirect_uri: guisso_settings[:redirect_uri],
          grant_type: "authorization_code"
        ]

        case HTTPoison.post(guisso_settings[:token_url], { :form, token_params }) do
          {:ok, response} ->
            {:ok, %{ "id_token" => id_token }} = Poison.decode(response.body)
            {:ok, token} = verify_jwt(id_token, guisso_settings[:client_secret])

            text conn, "Welcome #{token.claims["email"]}"

          _error ->
            text conn, "An error occurred while logging you in."
        end
      { :error, _cause } ->
        text conn, "An error occurred while logging you in."
    end
  end

  defp verify_jwt(id_token, client_secret) do
    token = Joken.token(id_token)

    sign_fn = case Joken.peek_header(token) do
                %{ "alg" => "HS256" } -> &Joken.hs256/1
                %{ "alg" => "HS384" } -> &Joken.hs384/1
                %{ "alg" => "HS512" } -> &Joken.hs512/1
              end

    signer = sign_fn.(client_secret)

    token = Joken.Signer.verify(token, signer)

    case token.errors do
      [] ->
        { :ok, token }
      _ ->
        :error
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
