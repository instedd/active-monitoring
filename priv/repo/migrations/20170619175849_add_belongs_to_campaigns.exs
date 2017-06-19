defmodule ActiveMonitoring.Repo.Migrations.AddBelongsToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :channel_id, references(:channels, on_delete: :nilify_all)
    end
  end
end
