defmodule ActiveMonitoring.Repo.Migrations.AddIndicesForSubjectsStats do
  use Ecto.Migration

  def change do
    create index(:calls, [:campaign_id, :subject_id], name: :calls_campaign_id_subject_id_index)
    create index(:calls, [:campaign_id, :subject_id, :current_step], name: :calls_campaign_id_subject_id_current_step_index)
  end
end
