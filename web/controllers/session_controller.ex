defmodule ActiveMonitoring.SessionController do
  use ActiveMonitoring.Web, :controller

  alias ActiveMonitoring.User
  alias Coherence.ControllerHelpers, as: Helpers
  alias Coherence.Rememberable
  use Coherence.Config

  import Rememberable, only: [gen_cookie: 3]


  @doc """
  Begin the login with Guisso using OpenId Connect.
  Flow continues at `oauth_callback`.
  """
  def login(conn, _params) do
    {conn, url} = Guisso.auth_code_url(conn)

    redirect(conn, external: url)
  end

  @doc """
  Completes the login process after the user has authorized Guisso to provide us
  access to his/her account information.
  """
  def oauth_callback(conn, params) do
    {:ok, email} = Guisso.request_auth_token(conn, params)

    user = Config.repo.one(from u in User, where: field(u, :email) == ^email)

    if user != nil do
      Coherence.Authentication.Session.create_login(conn, user, [id_key: Config.schema_key])
      |> Helpers.track_login(user, true)
      |> save_rememberable(user)
      |> put_flash(:notice, "Signed in successfully.")
      |> Helpers.redirect_to(:session_create, params)
    else
      # TODO
      text conn, "Welcome new user!"
    end
  end

  @doc """
  Logout the user.

  Delete the user's session, from an API call. Track the logout and delete the rememberable cookie,
  but don't redirect since that's a responsibility of the SPA.
  """
  def api_delete(conn, _params) do
    delete(conn)
    |> send_resp(204, "")
  end

  @doc """
  Logout the user.

  Delete the user's session, track the logout and delete the rememberable cookie.
  """
  def delete(conn, params) do
    delete(conn)
    |> Helpers.redirect_to(:session_delete, params)
  end


  defp delete(conn) do
    user = conn.assigns[Config.assigns_key]
    apply(Config.auth_module, Config.delete_login, [conn])
    |> track_logout(user)
    |> delete_rememberable(user)
  end


  defp save_rememberable(conn, user) do
    {changeset, series, token} = Rememberable.create_login(user)
    Config.repo.insert! changeset
    save_login_cookie conn, user.id, series, token, Config.login_cookie, Config.rememberable_cookie_expire_hours * 60 * 60
  end

  def save_login_cookie(conn, id, series, token, key \\ "coherence_login", expire \\ 2*24*60*60) do
    put_resp_cookie conn, key, gen_cookie(id, series, token), max_age: expire
  end

  defp track_logout(conn, user) do
    Helpers.changeset(:session, user.__struct__, user,
      %{
        last_sign_in_at: user.current_sign_in_at,
        last_sign_in_ip: user.current_sign_in_ip,
        current_sign_in_at: nil,
        current_sign_in_ip: nil
      })
      |> Config.repo.update
    conn
  end

  def delete_rememberable(conn, %{id: id}) do
    if Config.has_option :rememberable do
      where(Rememberable, [u], u.user_id == ^id)
      |> Config.repo.delete_all
      conn
      |> delete_resp_cookie(Config.login_cookie)
    else
      conn
    end
  end

end
