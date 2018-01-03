defmodule ActiveMonitoring.Repo.Migrations.AddLastReminderTimeToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :last_reminder_time, :utc_datetime
    end
    create index(:campaigns, [:started_at, :last_reminder_time], name: :campaigns_started_at_last_remainder_time_index)
  end
end
