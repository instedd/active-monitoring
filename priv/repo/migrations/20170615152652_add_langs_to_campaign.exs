defmodule ActiveMonitoring.Repo.Migrations.AddLangsToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :langs, {:array, :string}
    end
  end
end
