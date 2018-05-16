defmodule ActiveMonitoring.Runtime.VerboiceChannel do
  alias __MODULE__
  alias ActiveMonitoring.Router.Helpers
  use ActiveMonitoring.Web, :model
  require Plug.Conn
  @behaviour ActiveMonitoring.Runtime.ChannelProvider
  defstruct [:client, :channel_name]

  def new(channel) do
    channel_name = channel.settings["verboice_channel"]
    client = create_client(channel.user_id, channel.base_url)
    %VerboiceChannel{client: client, channel_name: channel_name}
  end

  def oauth2_authorize(code, redirect_uri, _base_url) do
    guisso_config = guisso_configuration()

    client = OAuth2.Client.new([
      client_id: guisso_config[:client_id],
      redirect_uri: redirect_uri,
      token_url: "#{guisso_config[:base_url]}/oauth2/token",
    ])

    client = OAuth2.Client.get_token!(client,
      code: code,
      client_secret: guisso_config[:client_secret],
      token_type: "bearer")

    client.token
  end

  defp guisso_configuration do
    verboice_config = Application.get_env(:active_monitoring, :verboice)
    verboice_config[:guisso]
  end

  def oauth2_refresh(access_token, _base_url) do
    guisso_config = guisso_configuration()

    client = OAuth2.Client.new([
      token: access_token,
      client_id: guisso_config[:client_id],
      token_url: "#{guisso_config[:base_url]}/oauth2/token",
    ])

    client = OAuth2.Client.refresh_token!(client,
      client_secret: guisso_config[:client_secret])

    client.token
  end

  defp create_client(user_id, base_url) do
    oauth_token = ActiveMonitoring.OAuthTokenServer.get_token "verboice", base_url, user_id
    Verboice.Client.new(base_url, oauth_token)
  end

  def get_channels(user_id), do: get_channels(user_id, Application.get_env(:active_monitoring, :verboice)[:base_url])
  def get_channels(user_id, base_url) do
    client = create_client(user_id, base_url)

    case client |> Verboice.Client.get_channels do
      {:ok, channel_names} ->
        channel_names

      _ -> :error
    end
  end

  def call(%{id: campaign_id, channel: channel, user_id: user_id}, %{contact_address: contact_address}) do
    base_url = Application.get_env(:active_monitoring, :verboice)[:base_url]
    create_client(user_id, base_url)
    |> Verboice.Client.call(address: contact_address,
                            channel: channel,
                            callback_url: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :callback, campaign_id),
                            status_callback_url: Helpers.verboice_callbacks_url(ActiveMonitoring.Endpoint, :status, campaign_id))
    |> ActiveMonitoring.Runtime.VerboiceChannel.process_call_response
  end

  def process_call_response(response) do
    case response do
      {:ok, %{"call_id" => call_id}} ->
        {:ok, %{verboice_call_id: call_id}}
      {:error, error} ->
        {:error, error}
      _ ->
        {:error, response}
    end
  end

  defimpl ActiveMonitoring.Runtime.Channel, for: ActiveMonitoring.Runtime.VerboiceChannel do
    def has_queued_message?(channel, %{"verboice_call_id" => call_id}) do
      response = channel.client
      |> Verboice.Client.call_state(call_id)
      case response do
        {:ok, %{"state" => "completed"}} -> false
        {:ok, %{"state" => "failed"}} -> false
        {:ok, %{"state" => "canceled"}} -> false
        {:ok, %{"state" => _}} -> true
        _ -> false
      end
    end
    def has_queued_message?(_, _) do
      false
    end

    def cancel_message(channel, %{"verboice_call_id" => call_id}) do
      channel.client
      |> Verboice.Client.cancel(call_id)
    end
    def cancel_message(_, _) do
      :ok
    end
  end
end
