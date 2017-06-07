defmodule ActiveMonitoring.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :provider, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

  end
end
