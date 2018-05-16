defmodule ActiveMonitoring.Channel do
  import Ecto.Query

  alias ActiveMonitoring.{Repo, Campaign}

  def verify_exclusive(channel_name) do
    campaign_count = Repo.one(from camp in Campaign, where: camp.channel == ^channel_name and not(is_nil(camp.started_at)), select: count("id"))
    campaign_count == 0
  end

  def provider(name) do
    channel_config = Application.get_env(:active_monitoring, :channel)
    channel_config[:providers][name]
  end
end
