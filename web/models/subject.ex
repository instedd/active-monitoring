defmodule ActiveMonitoring.Subject do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Call}

  schema "subjects" do
    field :phone_number, :string

    has_many :calls, Call

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:phone_number])
  end
end
