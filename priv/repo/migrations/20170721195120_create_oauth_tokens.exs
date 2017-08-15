defmodule ActiveMonitoring.Repo.Migrations.CreateOauthTokens do
  use Ecto.Migration

  def change do
    create table(:oauth_tokens) do
      add :provider, :string
      add :access_token, :map
      add :base_url, :string
      add :expires_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create unique_index(:oauth_tokens, [:user_id, :provider])

  end
end
