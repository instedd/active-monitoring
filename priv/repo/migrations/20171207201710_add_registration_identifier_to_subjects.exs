defmodule ActiveMonitoring.Repo.Migrations.AddRegistrationIdentifierToSubjects do
  use Ecto.Migration

  def change do
    alter table(:subjects) do
      add :registration_identifier, :string
    end
    create unique_index(:subjects, [:campaign_id, :registration_identifier], name: :subjects_campaign_id_registration_identifier_index)
  end
end
