defmodule ActiveMonitoring.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add :name, :string

      add :timezone, :string
      add :forward_number, :string
      add :symptoms, :string
      add :monitor_duration, :integer
      add :monitor_frequency, :integer
      add :time_start, :time
      add :time_end, :time
      add :retry_config, :string
      add :alerts_config, :string
      add :additional_fields, :string
      add :languages, :string

      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime

      timestamps()
    end
  end
end
