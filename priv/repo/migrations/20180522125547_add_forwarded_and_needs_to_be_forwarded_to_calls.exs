defmodule ActiveMonitoring.Repo.Migrations.AddForwardedAndNeedsToBeForwardedToCalls do
  use Ecto.Migration

  def change do
    alter table(:calls) do
      add :needs_to_be_forwarded, :boolean, default: false
      add :forwarded, :boolean, default: false
    end
    create index(:calls, [:needs_to_be_forwarded, :forwarded], name: :calls_needs_to_be_forwarded_forwarded_index)
  end
end
