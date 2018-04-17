defprotocol ActiveMonitoring.Runtime.Channel do
  def has_queued_message?(channel, channel_state)
  def cancel_message(channel, channel_state)
end

defmodule ActiveMonitoring.Runtime.ChannelProvider do
  @callback new(channel :: ActiveMonitoring.Channel) :: ActiveMonitoring.Runtime.Channel
  @callback oauth2_authorize(code :: String.t, redirect_uri :: String.t, base_url :: String.t) :: OAuth2.AccessToken.t
  @callback oauth2_refresh(access_token :: OAuth2.AccessToken.t, base_url :: String.t) :: OAuth2.AccessToken.t
end
