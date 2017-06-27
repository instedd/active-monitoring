defmodule ActiveMonitoring.Channel do
  use ActiveMonitoring.Web, :model

  import Ecto.Query, only: [from: 2]

  alias ActiveMonitoring.{User, Campaign}

  schema "channels" do
    field :name, :string
    field :uuid, Ecto.UUID

    belongs_to :user, User
    has_one :active_campaign, Campaign

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :uuid, :user_id])
    |> assoc_constraint(:user)
  end

  def with_active_campaign(query) do
    from channel in query,
      preload: [active_campaign: ^Campaign.active(Campaign)]
  end
end
