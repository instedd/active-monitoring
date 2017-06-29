defmodule ActiveMonitoring.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :phone_number, :string

      timestamps()
    end

    alter table(:calls) do
      add :subject_id, references(:subjects)
    end
  end
end
