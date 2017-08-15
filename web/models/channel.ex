defmodule ActiveMonitoring.Channel do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{User, Repo, Campaign}

  schema "channels" do
    field :name, :string
    field :uuid, Ecto.UUID
    # Column is in DB, it'd be to divide "nuntium" and "verboice"
    field :provider, :string
    field :expires_at, Ecto.DateTime
    belongs_to :user, User

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :uuid, :user_id])
    |> assoc_constraint(:user)
  end

  def verify_exclusive(channel) do
    campaign_count = Repo.one(from camp in Campaign, where: camp.channel_id == ^channel.id and is_nil(camp.started_at), select: count("id"))
    campaign_count == 0
  end

  def list(user) do
    []
  end
end
