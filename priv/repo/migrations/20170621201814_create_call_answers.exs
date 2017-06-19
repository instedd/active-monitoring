defmodule ActiveMonitoring.Repo.Migrations.CreateCallAnswers do
  use Ecto.Migration

  def change do
    create table(:call_answers) do
      add :call_id, references(:calls, on_delete: :delete_all)
      add :campaign_id, references(:campaigns, on_delete: :delete_all)
      add :symptom, :string
      add :response, :boolean

      timestamps(updated_at: false)
    end
  end
end
