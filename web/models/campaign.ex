defmodule ActiveMonitoring.Campaign do
  use ActiveMonitoring.Web, :model

  schema "campaigns" do
    field :name, :string

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name])
  end
end
