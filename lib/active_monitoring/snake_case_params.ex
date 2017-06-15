defmodule ActiveMonitoring.SnakeCaseParams do
  def init(opts), do: opts

  def call(%{params: params} = conn, _opts) do
    try do
      %{conn | params: ProperCase.to_snake_case(params)}
    rescue
      # Handle non-enumerables, such as Plug.Uploads
      e in Protocol.UndefinedError ->
        conn
    end
  end
end
