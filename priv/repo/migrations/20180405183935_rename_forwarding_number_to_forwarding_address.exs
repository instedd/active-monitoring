defmodule ActiveMonitoring.Repo.Migrations.RenameForwardingNumberToForwardingAddress do
  use Ecto.Migration

  def change do
    rename table(:campaigns), :forwarding_number, to: :forwarding_address
  end
end
