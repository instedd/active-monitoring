defmodule ActiveMonitoring.Repo.Migrations.AddAidaBotIdToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :aida_bot_id, :string
    end
  end
end
