defmodule ActiveMonitoring.Repo.Migrations.AddIdToSymptoms do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :symptoms
      add :symptoms, {:array, {:array, :string}}
    end
  end
end
