defmodule ActiveMonitoring.Repo.Migrations.CleanupOldCoherenceFields do
  use Ecto.Migration

  def change do
    drop table(:invitations)

    alter table(:users) do
      remove :confirmation_sent_at
      remove :confirmation_token
      remove :confirmed_at
      remove :failed_attempts
      remove :locked_at
      remove :password_hash
      remove :reset_password_sent_at
      remove :reset_password_token
      remove :unlock_token
    end
  end
end
