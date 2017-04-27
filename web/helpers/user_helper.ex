defmodule User.Helper do
  def current_user(conn) do
    case conn.assigns do
      %{current_user: user} -> user
      _ -> nil
    end
  end
end
