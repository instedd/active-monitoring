defmodule ActiveMonitoring.Runtime.Flow do

  alias ActiveMonitoring.{Call, CallLog, CallAnswer, Repo, Campaign}
  alias ActiveMonitoring.Router.Helpers

  def handle(channel_id, call_sid, from, digits) do
    campaign = fetch_campaign(channel_id)
    call = fetch_or_insert_call(call_sid, from, channel_id, campaign.id)

    insert_call_log(call, digits)
    insert_call_answer(call, digits)

    language = fetch_or_choose_language(call, digits, campaign)
    step = next_step(campaign, call)

    Call.changeset(call, %{current_step: step, language: language}) |> Repo.update!

    action = action_for(step)
    audio = Campaign.audio_for(campaign, step, language)

    {:ok, {action, audio}}
  end

  def next_step(campaign, %Call{current_step: step}) do
    steps = Campaign.steps(campaign)
    index = Enum.find_index(steps, fn(s) -> s == step end) || -1
    Enum.fetch!(steps, index + 1)
  end

  defp action_for(step) do
    case step do
      step when step in ["welcome", "educational", "thanks"] -> :play
      step when step in ["forward"] -> :forward
      _ -> :gather
    end
  end

  defp fetch_or_choose_language(%Call{current_step: step, language: language}, digits, campaign) do
    if step == "language" do
      choose_language(digits, campaign)
    else
      language
    end
  end

  defp choose_language(digits, %Campaign{langs: langs}) do
    # TODO: Handle invalid choice and no choice at all
    option = String.to_integer(digits)
    Enum.fetch!(langs, option - 1)
  end

  defp fetch_campaign(channel_id) do
    Campaign |> Repo.get_by!(channel_id: channel_id)
  end

  defp fetch_or_insert_call(call_sid, from, channel_id, campaign_id) do
    case Call |> Repo.get_by(sid: call_sid) do
      nil ->
        Call.changeset(%Call{}, %{sid: call_sid, from: from, channel_id: channel_id, campaign_id: campaign_id}) |> Repo.insert!
      call ->
        call
    end
  end

  defp insert_call_log(%Call{id: call_id, current_step: current_step}, digits) do
    CallLog.changeset(%CallLog{}, %{call_id: call_id, step: current_step || "start", digits: digits}) |> Repo.insert!
  end

  defp insert_call_answer(%Call{id: call_id, campaign_id: campaign_id, current_step: current_step}, digits) do
    case Campaign.symptom_id(current_step) do
      nil ->
        :ok
      symptom ->
        CallAnswer.changeset(%CallAnswer{}, %{call_id: call_id, campaign_id: campaign_id, symptom: symptom, response: digits_to_response(digits)})
          |> Repo.insert!
    end
  end

  defp digits_to_response("1"), do: true
  defp digits_to_response("3"), do: false
  defp digits_to_response(_),   do: nil

end
