defmodule ActiveMonitoring.Repo.Migrations.AddFacebookConfigToCampaigns do
  use Ecto.Migration

  def change do
    alter table(:campaigns) do
      add :fb_page_id, :string
      add :fb_verify_token, :string
      add :fb_access_token, :string
    end
  end
end
