defmodule ActiveMonitoring.Repo.Migrations.AddModeToCampaign do
  use Ecto.Migration

  def up do
    alter table(:campaigns) do
      add :mode, :string, null: true
    end

    execute "UPDATE campaigns set mode = 'call'"

    alter table(:campaigns) do
      modify :mode, :string, null: false
    end
  end

  def down do
    alter table(:campaigns) do
      remove :mode
    end
  end
end
