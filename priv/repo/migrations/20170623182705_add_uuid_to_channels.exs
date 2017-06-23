defmodule ActiveMonitoring.Repo.Migrations.AddUuidToChannels do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :uuid, :uuid
    end

    create unique_index(:channels, [:uuid])
  end
end
