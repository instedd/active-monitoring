defmodule ActiveMonitoring.Channel do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Repo,User}

  schema "channels" do
    field :name, :string
    field :uuid, Ecto.UUID
    belongs_to :user, User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :uuid, :user_id])
    |> assoc_constraint(:user)
  end
end
