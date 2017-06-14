defmodule ActiveMonitoring.Types.TripleArray do
  @behaviour Ecto.Type
  def type, do: { :array, { :array, :string } }

  def cast(list) when is_list(list) do
    cond do
      Enum.all?(list, &(length(&1) == 3)) ->
        {:ok, list}
      true ->
        :error
    end
  end

  def cast(_), do: :error

  def load(list), do: {:ok, list}

  def dump(list) when is_list(list), do: {:ok, list}
  def dump(_), do: :error
end
