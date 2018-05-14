defmodule ActiveMonitoring.Repo.Migrations.AddUniquenessConstraintsToCallsAndAnswers do
  use Ecto.Migration

  def change do
    create index(:call_answers, [:symptom, :call_id], unique: true)
    create index(:calls, [:campaign_id, :subject_id, :inserted_at], unique: true)
  end
end
