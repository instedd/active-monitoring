defmodule Verboice.Client do
  alias __MODULE__
  defstruct [:base_url, :oauth2_client]

  def new(url, token) do
    oauth2_client = OAuth2.Client.new(token: token)
    %Client{base_url: url, oauth2_client: oauth2_client}
  end

  def call(client, params) do
    url = "#{URI.merge(client.base_url, "api/call")}?#{URI.encode_query(params)}"

    client.oauth2_client
    |> OAuth2.Client.get(url)
    |> parse_response
  end

  def call_state(client, call_id) do
    url = "#{URI.merge(client.base_url, "api/calls/#{call_id}/state.json")}"
    client.oauth2_client
    |> OAuth2.Client.get(url)
    |> parse_response
  end

  def cancel(client, call_id) do
    url = "#{URI.merge(client.base_url, "api/calls/#{call_id}/cancel.json")}"
    client.oauth2_client
    |> OAuth2.Client.post(url)
    |> parse_response
  end

  def get_channels(client) do
    url = URI.merge(client.base_url, "/api/channels") |> URI.to_string

    client.oauth2_client
    |> OAuth2.Client.get(url)
    |> parse_response
  end

  def create_project(client, options) do
    url = URI.merge(client.base_url, "/api/projects/create") |> URI.to_string

    client.oauth2_client
    |> OAuth2.Client.post(url, %{project: options})
    |> parse_response
  end

  defp parse_response(response) do
    case response do
      {:ok, response = %{status_code: 200}} ->
        {:ok, response.body}
      {:ok, response} ->
        {:error, response.status_code}
      {:error, %OAuth2.Error{reason: reason}} ->
        {:error, reason}
      {:error, %OAuth2.Response{body: %{"error" => reason}}} ->
        {:error, reason}
    end
  end

end
