defmodule ActiveMonitoring.Repo.Migrations.RenameSubjectsPhoneNumberToContactAddress do
  use Ecto.Migration

  def change do
    rename table(:subjects), :phone_number, to: :contact_address
  end
end
