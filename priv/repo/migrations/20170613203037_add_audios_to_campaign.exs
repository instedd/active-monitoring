defmodule ActiveMonitoring.Repo.Migrations.AddAudiosToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :audios, {:array, {:array, :string}}
    end
  end
end
