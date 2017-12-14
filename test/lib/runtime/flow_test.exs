defmodule ActiveMonitoring.Runtime.FlowTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{Flow}
  alias ActiveMonitoring.{Call, CallLog, CallAnswer, Repo, Subject}
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
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      response = Flow.handle_status(campaign.id, "CALL_SID_1", "9990001", "ringing")
      {:ok, campaign: campaign, response: response}
    end

    @tag :skip
    test "it should create a new call", %{campaign: campaign} do
      call = Repo.one!(Call)
      assert %Call{sid: "CALL_SID_1", current_step: nil} = call
      assert call.campaign_id == campaign.id
    end

    @tag :skip
    test "it should create a new subject for new number", %{campaign: campaign} do
      subject = Repo.one!(Subject) |> Repo.preload(:calls)
      assert %Subject{phone_number: "9990001"} = subject
      [call | _tail] = subject.calls
      assert call.sid == "CALL_SID_1"
      assert call.campaign_id == campaign.id
      assert subject.phone_number == "9990001"
    end

    @tag :skip
    test "it should find subject if same phone number is used", %{campaign: campaign} do
      Flow.handle_status(campaign.id, "CALL_SID_2", "9990001", "ringing")
      subjects = Repo.all(Subject)
      assert length(subjects) == 1
    end
  end

  # describe "invalid call" do
  #   test "it should raise if campaign isn't active" do
  #     assert_raise Ecto.NoResultsError, fn ->
  #       Flow.handle_status(campaign.id, "CALL_SID_1", "9990001", "ringing")
  #     end
  #   end

  #   test "it should raise if unused channel on callback" do
  #     channel = build(:channel) |> Repo.insert!
  #     assert_raise Ecto.NoResultsError, fn ->
  #       Flow.handle(channel.id, "CALL_SID_1", "")
  #     end
  #   end
  # end

  describe "welcome message" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign) |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "2")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should answer with language audio", %{response: response} do
      assert {:gather, %{audio: "id-language"}} = response
    end

    test "it should create a call log" do
      assert %CallLog{step: "start"} = (CallLog |> Query.last |> Repo.one!)
    end
  end

  describe "answer language" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign) |> on_step("language") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "2")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "welcome"} = Repo.one!(Call)
    end

    test "it should set call language" do
      assert %Call{language: "es"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "language", digits: "2", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with welcome message", %{response: response} do
      assert {:play, %{audio: "id-welcome-es"}} = response
    end
  end

  describe "callback on welcome message" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("welcome") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-fever"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "welcome", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:id-fever-es"}} = response
    end
  end

  describe "answer positive symptom" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-fever") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "1")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-rash"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:id-fever", call_id: ^call_id, digits: "1"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:id-rash-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "id-fever", response: true, call_id: ^call_id, campaign_id: ^campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "answer negative symptom" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-fever") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:id-rash"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:id-fever", call_id: ^call_id, digits: "3"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:id-rash-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "id-fever", response: false, call_id: ^call_id, campaign_id: ^campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "forwarding call on all symptoms" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner, forwarding_condition: "all") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      build(:call_answer, symptom: "id-fever", response: true) |> for_call(call) |> Repo.insert!
      {:ok, campaign: campaign, call: call}
    end

    test "it should forward the call on all symptoms positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.id, call.sid, "1")

      assert %Call{current_step: "forward"} = Repo.one!(Call)
      assert {:forward, %{audio: "id-forward-es"}} = response
    end

    test "it should not forward the call if not all symptoms are positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:play, %{audio: "id-educational-es"}} = response
    end
  end

  describe "forwarding call on any positive symptom" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner, forwarding_condition: "any") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      build(:call_answer, symptom: "id-fever", response: false) |> for_call(call) |> Repo.insert!
      {:ok, campaign: campaign, call: call}
    end

    test "it should forward the call if any symptom is positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.id, call.sid, "1")

      assert %Call{current_step: "forward"} = Repo.one!(Call)
      assert {:forward, %{audio: "id-forward-es"}} = response
    end

    test "it should not forward the call if not no symptom is positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:play, %{audio: "id-educational-es"}} = response
    end
  end

  describe "additional information" do
    setup do
      owner = build(:user) |> Repo.insert!
      {:ok, owner: owner}
    end

    test "it should play educational message if compulsory", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "compulsory") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:play, %{audio: "id-educational-es"}} = response
    end

    test "it should skip educational message if disabled", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "zero") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "thanks"} = Repo.one!(Call)
      assert {:hangup, %{audio: "id-thanks-es"}} = response
    end

    test "it should ask for confirmation if optional", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "optional") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:id-rash") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "additional_information_intro"} = Repo.one!(Call)
      assert {:gather, %{audio: "id-additional_information_intro-es"}} = response
    end

    test "it should play educational message if user chooses to", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "optional") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("additional_information_intro") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "1")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:play, %{audio: "id-educational-es"}} = response
    end

    test "it should skip educational message if user chooses to", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "optional") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("additional_information_intro") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "thanks"} = Repo.one!(Call)
      assert {:hangup, %{audio: "id-thanks-es"}} = response
    end
  end

  describe "callback on educational message" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("educational") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "thanks"} = Repo.one!(Call)
    end

    test "it should answer with last message", %{response: response} do
      assert {:hangup, %{audio: "id-thanks-es"}} = response
    end
  end

end
