defmodule ActiveMonitoring.Runtime.VerboiceChannel do
  alias __MODULE__
  use ActiveMonitoring.Web, :model
  alias ActiveMonitoring.{Repo, Channel}
  alias ActiveMonitoring.Runtime.{Flow}
  alias ActiveMonitoring.Router.Helpers
  import Plug.Conn
  @behaviour ActiveMonitoring.Runtime.ChannelProvider
  defstruct [:client, :channel_name]

  def new(channel) do
    channel_name = channel.settings["verboice_channel"]
    client = create_client(channel.user_id, channel.base_url)
    %VerboiceChannel{client: client, channel_name: channel_name}
  end

  def oauth2_authorize(code, redirect_uri, base_url) do
    guisso_config = guisso_configuration

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

  def oauth2_refresh(access_token, base_url) do
    guisso_config = guisso_configuration

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

  # def sync_channels(user_id, base_url, channel_names) do
  #   user = ActiveMonitoring.User |> Repo.get!(user_id)
  #   channels = user |> assoc(:channels) |> where([c], c.provider == "verboice" and c.base_url == ^base_url) |> Repo.all

  #   channels |> Enum.each(fn channel ->
  #     exists = channel_names |> Enum.any?(fn name -> channel.settings["verboice_channel"] == name end)
  #     if !exists do
  #       ActiveMonitoring.Channel.delete(channel)
  #     end
  #   end)

  #   channel_names |> Enum.each(fn name ->
  #     exists = channels |> Enum.any?(fn channel -> channel.settings["verboice_channel"] == name end)
  #     if !exists do
  #       user
  #       |> Ecto.build_assoc(:channels)
  #       |> Channel.changeset(%{name: name, type: "ivr", provider: "verboice", base_url: base_url, settings: %{"verboice_channel" => name}})
  #       |> Repo.insert
  #     end
  #   end)
  # end

  # defp channel_failed(respondent, "failed", %{"CallStatusReason" => "Busy", "CallStatusCode" => code}) do
  #   Broker.channel_failed(respondent, "User hangup (#{code})")
  # end

  # defp channel_failed(respondent, "failed", %{"CallStatusReason" => reason, "CallStatusCode" => code}) do
  #   Broker.channel_failed(respondent, "#{reason} (#{code})")
  # end

  # defp channel_failed(respondent, status, %{"CallStatusReason" => reason, "CallStatusCode" => code}) do
  #   Broker.channel_failed(respondent, "#{status}: #{reason} (#{code})")
  # end

  # defp channel_failed(respondent, "failed", %{"CallStatusReason" => "Busy"}) do
  #   Broker.channel_failed(respondent, "User hangup")
  # end

  # defp channel_failed(respondent, "failed", %{"CallStatusReason" => reason}) do
  #   Broker.channel_failed(respondent, "#{reason}")
  # end

  # defp channel_failed(respondent, status, %{"CallStatusReason" => reason}) do
  #   Broker.channel_failed(respondent, "#{status}: #{reason}")
  # end

  # defp channel_failed(respondent, "failed", %{"CallStatusCode" => code}) do
  #   Broker.channel_failed(respondent, "(#{code})")
  # end

  # defp channel_failed(respondent, status, %{"CallStatusCode" => code}) do
  #   Broker.channel_failed(respondent, "#{status} (#{code})")
  # end

  # defp channel_failed(respondent, status, _) do
  #   Broker.channel_failed(respondent, status)
  # end

  defimpl ActiveMonitoring.Runtime.Channel, for: ActiveMonitoring.Runtime.VerboiceChannel do
    def has_delivery_confirmation?(_), do: false
    def ask(_, _, _, _), do: throw(:not_implemented)
    def prepare(_, _), do: :ok

    def setup(channel, respondent, token) do
      channel.client
      |> Verboice.Client.call(address: respondent.sanitized_phone_number,
                              channel: channel.channel_name,
                              callback_url: VerboiceChannel.callback_url(respondent),
                              status_callback_url: VerboiceChannel.status_callback_url(respondent, token))
      |> ActiveMonitoring.Runtime.VerboiceChannel.process_call_response
    end

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
