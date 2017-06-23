defmodule ActiveMonitoring.Runtime.FlowTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{Flow}
  alias ActiveMonitoring.{Call, CallLog, CallAnswer, Campaign, Repo}
  alias Ecto.Query

  import ActiveMonitoring.Factory

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ActiveMonitoring.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ActiveMonitoring.Repo, {:shared, self()})
    end

    :ok
  end

  describe "new call" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      response = Flow.handle(campaign.channel_id, "CALL_SID_1", "9990001", "")
      {:ok, campaign: campaign, response: response}
    end

    test "it should create a new call", %{campaign: campaign} do
      assert call = Repo.one!(Call)
      assert %Call{sid: "CALL_SID_1", from: "9990001", current_step: "language"} = call
      assert call.campaign_id == campaign.id
      assert call.channel_id == campaign.channel_id
    end

    test "it should answer with language audio", %{response: response} do
      assert {:ok, {:gather, "id-language"}} = response
    end

    test "it should create a call log" do
      assert %CallLog{step: "start"} = (CallLog |> Query.last |> Repo.one!)
    end
  end

  describe "invalid call" do
    test "it should raise if unused channel" do
      channel = build(:channel) |> Repo.insert!
      assert_raise Ecto.NoResultsError, fn ->
        Flow.handle(channel.id, "CALL_SID_1", "9990001", "")
      end
    end
  end

  describe "answer language" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel) |> on_step("language") |> Repo.insert!
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "2")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "welcome"} = Repo.one!(Call)
    end

    test "it should set call language" do
      assert %Call{language: "es"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "language", digits: "2", call_id: call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with welcome message", %{response: response} do
      assert {:ok, {:play, "id-welcome-es"}} = response
    end
  end

  describe "callback on welcome message" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel, language: "es") |> on_step("welcome") |> Repo.insert!
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-fever"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "welcome", call_id: call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:ok, {:gather, "id-symptom:id-fever-es"}} = response
    end
  end

  describe "answer positive symptom" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel, language: "es") |> on_step("symptom:id-fever") |> Repo.insert!
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "1")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-rash"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:id-fever", call_id: call_id, digits: "1"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:ok, {:gather, "id-symptom:id-rash-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "id-fever", response: true, call_id: call_id, campaign_id: campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "answer negative symptom" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel, language: "es") |> on_step("symptom:id-fever") |> Repo.insert!
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "3")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-rash"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:id-fever", call_id: call_id, digits: "3"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:ok, {:gather, "id-symptom:id-rash-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "id-fever", response: false, call_id: call_id, campaign_id: campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "forwarding call on all symptoms" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner, forwarding_condition: "all") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      build(:call_answer, symptom: "id-fever", response: true) |> for_call(call) |> Repo.insert!
      {:ok, campaign: campaign, call: call}
    end

    test "it should forward the call on all symptoms positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "1")

      assert %Call{current_step: "forward"} = Repo.one!(Call)
      assert {:ok, {:forward, "id-forward-es"}} = response
    end

    test "it should not forward the call if not all symptoms are positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:ok, {:play, "id-educational-es"}} = response
    end
  end

  describe "forwarding call on any positive symptom" do
    setup context do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner, forwarding_condition: "any") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, channel: campaign.channel, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      build(:call_answer, symptom: "id-fever", response: false) |> for_call(call) |> Repo.insert!
      {:ok, campaign: campaign, call: call}
    end

    test "it should forward the call if any symptom is positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "1")

      assert %Call{current_step: "forward"} = Repo.one!(Call)
      assert {:ok, {:forward, "id-forward-es"}} = response
    end

    test "it should not forward the call if not no symptom is positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.channel_id, call.sid, call.from, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:ok, {:play, "id-educational-es"}} = response
    end
  end

end
