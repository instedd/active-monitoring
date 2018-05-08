defmodule ActiveMonitoring.Runtime.Broker do
  use GenServer
  use Timex
  import Ecto.Query
  require Logger
  alias ActiveMonitoring.{Repo, Campaign, Channel, AidaBot, Subject}

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
      active_campaigns_to_remind(now)
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

  defp active_campaigns_to_remind(now) do
    Repo.all(from c in Campaign, where: not(is_nil(c.started_at)) and (is_nil(c.last_reminder_time) or (c.last_reminder_time < ^Timex.shift(now, hours: -23))) )
    |> Repo.preload([subjects: :campaign])
  end

  defp is_it_time_to_remind_subjects(%{timezone: timezone}, now) do
    case Timex.Timezone.convert(now, timezone) do
      {:error, error} -> Logger.error inspect(error); false
      local_now ->
        local_3pm = Timex.set(local_now, [hour: 15, minute: 0, second: 0])
        Timex.before?(local_3pm, local_now)
    end
  end

  defp call_pending_subjects(%{subjects: subjects, mode: "chat"} = campaign, now) do
    subjects =
      subjects
      |> Enum.filter(fn s -> Subject.active_case(s, now) end)
      |> Enum.group_by(fn subject ->
        # TODO: Check with Mati if we asume the first day as day 0
        Timex.diff(now, subject.inserted_at, :days) + 1
      end)

    case campaign
         |> AidaBot.manifest(subjects)
         |> AidaBot.update(campaign.aida_bot_id) do
      {:ok, _} ->
        true

      {:error, reason} ->
        Logger.error("Error publishing manifest: #{campaign.aida_bot_id}\n#{inspect(reason)}\n\n")

      response ->
        Logger.error(
          "Unknown response publishing manifest: #{campaign.aida_bot_id}\n#{inspect(response)}\n\n"
        )
    end

    Campaign.mark_as_reminded(campaign, now)
  end

  defp call_pending_subjects(%{subjects: subjects} = campaign, now) do
    verboice_client = Channel.provider("verboice")
    pending_subjects = Campaign.subjects_pending_check_in(campaign, subjects, now)
    Enum.each pending_subjects, fn(subject) ->
      try do
        case verboice_client.call(campaign, subject) do
          {:ok, _} -> true
          {:error, reason} -> Logger.error "Error calling subject: #{inspect(reason)}\n#{inspect(subject)}\n\n"
          response -> Logger.error "Unknown response calling subject: #{inspect(response)}\n#{inspect(subject)}\n\n"
        end
      rescue
        e in RuntimeError -> Logger.error("Runtime error calling subject: #{inspect(e)}\n#{inspect(subject)}\n\n")
      end
    end
    Campaign.mark_as_reminded(campaign, now)
  end
end
