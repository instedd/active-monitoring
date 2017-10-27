defmodule ActiveMonitoring.User do
  use ActiveMonitoring.Web, :model
  use Coherence.Schema

  alias ActiveMonitoring.{OAuthToken, Channel, Repo, Campaign}

  schema "users" do
    field :name, :string
    field :email, :string
    has_many :oauth_tokens, OAuthToken
    has_many :campaigns, Campaign
    coherence_schema()

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :email] ++ coherence_fields())
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
    |> validate_coherence(params)
  end

  def channels(user) do
    Repo.all(from t in OAuthToken, where: t.user_id == ^user.id)
      |> Enum.map(fn (token) -> Channel.provider(token.provider).get_channels(user.id) end)
      |> List.flatten
  end
end
