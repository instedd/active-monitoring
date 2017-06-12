defmodule ActiveMonitoring.Repo.Migrations.AddFieldsToCampaign do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      remove :symptoms
      add :symptoms, {:array, :string}
      add :forwarding_condition, :string
      add :additional_information, :string
      add :alert_recipients, {:array, :string}
      remove :additional_fields
      add :additional_fields, {:array, :string}
    end

    rename table(:campaigns), :forward_number, to: :forwarding_number
  end
end
