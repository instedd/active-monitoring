defmodule ActiveMonitoring.Runtime.Flow do

  alias ActiveMonitoring.{Call, CallLog, CallAnswer, Repo, Campaign, Subject}

  def handle(campaign_id, call_sid, digits) do
    campaign = fetch_campaign(campaign_id)
    call = fetch_call(call_sid)

    insert_call_log(call, digits)
    insert_call_answer(call, digits)

    language = fetch_or_choose_language(call, digits, campaign)
    call = associate_call_subject(call, digits, campaign)
    step = next_step(campaign, call, digits) |> check_forward(campaign, call, digits)
    Call.changeset(call, %{current_step: step, language: language}) |> Repo.update!

    action = action_for(step)
    {action, data_for(action, campaign, step, language)}
  end

  def handle_status(campaign_id, call_sid, from, _status) do
    fetch_or_insert_call(call_sid, from, campaign_id)
    :ok
  end

  defp next_step(_campaign, %{current_step: "additional_information_intro"}, digits) do
    if digits_to_response(digits), do: "educational", else: "thanks"
  end
  defp next_step(_campaign, %{current_step: "registration"}, _digits), do: "identify"
  defp next_step(campaign, %{current_step: "identify", subject_id: subject_id}, _digits)
    when not(is_nil(subject_id)),
    do: Campaign.symptom_steps(campaign) |> hd
  defp next_step(campaign, %{current_step: step}, _digits) do
    steps = Campaign.steps(campaign)
    index = Enum.find_index(steps, fn(s) -> s == step end) || -1
    Enum.fetch!(steps, index + 1)
  end

  defp data_for(:forward, campaign, step, language), do:
    %{audio: Campaign.audio_for(campaign, step, language), number: campaign.forwarding_number}
  defp data_for(:gather, campaign, "identify", language), do:
    %{audio: Campaign.audio_for(campaign, "identify", language), finish_on_key: "#"}
  defp data_for(_action, campaign, step, language), do:
    %{audio: Campaign.audio_for(campaign, step, language)}

  defp check_forward("forward", campaign, call, digits) do
    call = Repo.preload call, :call_answers
    if Campaign.should_forward(campaign, call.call_answers), do: "forward", else: next_step(campaign, %{call | current_step: "forward"}, digits)
  end
  defp check_forward(step, _campaign, _call, _digits), do: step

  defp action_for(step) do
    case step do
      step when step in ["welcome", "educational"] -> :play
      step when step in ["registration", "forward"] -> :forward
      step when step in ["thanks"] -> :hangup
      _ -> :gather
    end
  end

  defp fetch_or_choose_language(%Call{current_step: "language"}, digits, campaign), do:
    choose_language(digits, campaign)
  defp fetch_or_choose_language(%Call{language: language}, _digits, _campaign), do:
    language

  defp choose_language(digits, %Campaign{langs: langs}) do
    # TODO: Handle invalid choice and no choice at all
    option = String.to_integer(digits)
    Enum.fetch!(langs, option - 1)
  end

  defp associate_call_subject(%Call{current_step: "identify"} = call, digits, campaign) do
    case fetch_subject(digits, campaign.id) do
      nil -> call
      subject -> Call.assign_subject(call, subject)
    end
  end
  defp associate_call_subject(call, _digits, _campaign), do: call

  defp fetch_campaign(campaign_id) do
    Campaign |> Repo.get!(campaign_id)
  end

  defp fetch_call(call_sid) do
    Call |> Repo.get_by(sid: call_sid)
  end

  defp fetch_subject(registration_identifier, campaign_id) do
    Subject |> Repo.get_by(registration_identifier: registration_identifier, campaign_id: campaign_id)
  end

  defp fetch_or_insert_call(call_sid, from, campaign_id) do
    case fetch_call(call_sid) do
      nil ->
        Call.changeset(%Call{}, %{sid: call_sid, campaign_id: campaign_id, from: from}) |> Repo.insert!
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
