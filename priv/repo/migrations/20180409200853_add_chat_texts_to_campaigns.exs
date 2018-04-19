defmodule ActiveMonitoring.Repo.Migrations.AddChatTextsToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :chat_texts, {:array, {:array, :string}}
    end
  end
end
