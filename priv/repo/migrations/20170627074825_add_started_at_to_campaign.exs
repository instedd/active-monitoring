defmodule ActiveMonitoring.Repo.Migrations.AddStartedAtToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :started_at, :datetime
    end
  end
end
