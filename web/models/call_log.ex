defmodule ActiveMonitoring.CallLog do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Repo, Call}

  schema "call_logs" do
    field :step, :string
    field :digits, :string

    belongs_to :call, Call

    timestamps(updated_at: false)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:step, :digits, :call_id])
  end
end
