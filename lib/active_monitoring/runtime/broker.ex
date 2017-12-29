defmodule ActiveMonitoring.Runtime.Broker do
  use GenServer
  use Timex
  import Ecto.Query
  import Ecto
  require Logger
  alias ActiveMonitoring.{Repo, Campaign, Channel}

  @poll_interval :timer.minutes(15)
  @server_ref {:global, __MODULE__}

  def server_ref, do: @server_ref

  def start_link do
    GenServer.start_link(__MODULE__, [], name: @server_ref)
  end

  # Makes the borker performs a poll on the surveys.
  # This method is intended to be used by tests.
  def poll do
    GenServer.call(@server_ref, :poll)
  end

  def handle_call(:poll, _from, state) do
    handle_info(:poll, state)
    {:reply, :ok, state}
  end

  def init(_args) do
    :timer.send_after(1000, :poll)
    {:ok, nil}
  end

  def handle_info(:poll, state, now) do
    try do
      all_active_campaigns()
      |> Enum.filter(&is_it_time_to_remind_subjects(&1, now))
      |> Enum.each(&call_pending_subjects(&1, now))

      {:noreply, state}
    after
      :timer.send_after(@poll_interval, :poll)
    end
  end

  def handle_info(:poll, state) do
    handle_info(:poll, state, Timex.now)
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp all_active_campaigns do
    Repo.all(from c in Campaign, where: not(is_nil(c.started_at))) |> Repo.preload(:subjects) |> Repo.preload([subjects: :campaign])
  end

  defp is_it_time_to_remind_subjects(%{timezone: timezone}, now) do
    case Timex.Timezone.convert(now, timezone) do
      {:error, error} -> Logger.error inspect(error); false
      local_now ->
        local_3pm = Timex.set(local_now, [hour: 15, minute: 0, second: 0])
        last_poll_date = Timex.shift(local_now, milliseconds: -@poll_interval)
        Timex.between?(local_3pm, last_poll_date, local_now)
    end
  end

  defp call_pending_subjects(%{subjects: subjects} = campaign, now) do
    verboice_client = Channel.provider("verboice")
    pending = Campaign.subjects_pending_check_in(campaign, subjects, now)
    Enum.each pending, &verboice_client.call(campaign, &1)
  end
end
