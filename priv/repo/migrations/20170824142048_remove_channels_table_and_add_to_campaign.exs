defmodule ActiveMonitoring.Repo.Migrations.RemoveChannelsTableAndAddToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :channel_id
      add :channel, :string
    end

    alter table(:calls) do
      remove :channel_id
    end

    drop table(:channels)
  end
end
