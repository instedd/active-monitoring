defmodule ActiveMonitoring.Repo.Migrations.AddCampaignToSubjects do
  use Ecto.Migration

  def change do
    alter table(:subjects) do
      add :campaign_id, references(:campaigns)
    end
  end
end
