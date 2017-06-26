defmodule ActiveMonitoring.Repo.Migrations.CreateCalls do
  use Ecto.Migration

  def change do
    create table(:calls) do
      add :sid, :string
      add :from, :string
      add :campaign_id, references(:campaigns, on_delete: :nilify_all)
      add :channel_id, references(:channels, on_delete: :nilify_all)
      add :current_step, :string
      add :language, :string

      timestamps()
    end

    unique_index(:calls, [:sid])

    create table(:call_logs) do
      add :call_id, references(:calls)
      add :step, :string
      add :digits, :string

      timestamps(updated_at: false)
    end
  end
end
