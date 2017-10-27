defmodule ActiveMonitoring.UnauthorizedError do
  defexception plug_status: 403, message: "unauthorized", conn: nil

  def exception(opts) do
    conn   = Keyword.fetch!(opts, :conn)
    path   = "/" <> Enum.join(conn.path_info, "/")

    %ActiveMonitoring.UnauthorizedError{
      message: "not authorized for #{conn.method} #{path}",
      conn: conn
    }
  end
end

defimpl Plug.Exception, for: ActiveMonitoring.UnauthorizedError do
  def status(_), do: 403
end
