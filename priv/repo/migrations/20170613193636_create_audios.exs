defmodule ActiveMonitoring.Repo.Migrations.CreateAudios do
  use Ecto.Migration

  def change do
    create table(:audios) do
      add :uuid, :string
      add :data, :bytea
      add :filename, :string
      add :duration, :integer

      timestamps()
    end
  end
end
