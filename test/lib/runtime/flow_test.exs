defmodule ActiveMonitoring.Runtime.FlowTest do
  use ExUnit.Case

  alias ActiveMonitoring.Runtime.{Flow}
  alias ActiveMonitoring.{Call, CallLog, CallAnswer, Repo}
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
      {:ok, campaign: campaign}
    end

    test "it should create a new call", %{campaign: campaign} do
      Flow.handle_status(campaign.id, "CALL_SID_1", "9990001", "ringing")
      call = Repo.one!(Call)
      assert %Call{sid: "CALL_SID_1", current_step: nil} = call
      assert call.campaign_id == campaign.id
    end

    test "it should not infer the subject (not even by contact address)", %{campaign: campaign} do
      build(:subject, campaign: campaign, contact_address: "9990001") |> Repo.insert!

      Flow.handle_status(campaign.id, "CALL_SID_1", "9990001", "ringing")

      assert %Call{sid: "CALL_SID_1", current_step: nil, subject_id: nil} = Repo.one!(Call)
    end

    test "it should not infer the subject (not even by registration identifier)", %{campaign: campaign} do
      build(:subject, campaign: campaign, registration_identifier: "9990001") |> Repo.insert!

      Flow.handle_status(campaign.id, "CALL_SID_1", "9990001", "ringing")

      assert %Call{sid: "CALL_SID_1", current_step: nil, subject_id: nil} = Repo.one!(Call)
    end
  end

  describe "welcome message" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign) |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, nil)
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should answer with language audio", %{response: response} do
      assert {:gather, %{audio: "id-language"}} = response
    end

    test "it should create a call log" do
      assert %CallLog{step: "start"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should initialize the current step" do
      assert %Call{current_step: "language"} = (Call |> Query.last |> Repo.one!)
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
      response = Flow.handle(campaign.id, call.sid, nil)
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "identify"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "welcome", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with identify message", %{response: response} do
      assert {:gather, %{audio: "id-identify-es", finish_on_key: "#"}} = response
    end
  end

  describe "identifies a registered subject" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      subject = build(:subject, campaign: campaign, registration_identifier: "123") |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("identify") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "123")
      {:ok, campaign: campaign, call: call, response: response, subject: subject}
    end

    test "it should move on to the first symptom" do
      assert %Call{current_step: "symptom:123e4567-e89b-12d3-a456-426655440111"} = Repo.one!(Call)
    end

    test "it should assign the call's subject", %{subject: %{id: subject_id}} do
      assert %Call{subject_id: ^subject_id} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "identify", digits: "123", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:123e4567-e89b-12d3-a456-426655440111-es"}} = response
    end
  end

  describe "identifies an invalid subject registration ID" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("identify") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "123")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance the call to registration" do
      assert %Call{current_step: "registration"} = Repo.one!(Call)
    end

    test "it should not assign the call's subject" do
      assert %Call{subject_id: nil} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "identify", digits: "123", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should forward the call for registration", %{response: response} do
      assert {:forward, %{audio: "id-registration-es", number: "5550000"}} = response
    end
  end

  describe "registration of a new subject" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("registration") |> Repo.insert!
      subject = build(:subject, campaign: campaign, contact_address: "9990001") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, nil)
      {:ok, campaign: campaign, call: call, response: response, subject: subject}
    end

    test "it should go back to identify step" do
      assert %Call{current_step: "identify"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "registration", call_id: ^call_id} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with identify message", %{response: response} do
      assert {:gather, %{audio: "id-identify-es", finish_on_key: "#"}} = response
    end
  end

  describe "answer positive symptom" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440111") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "1")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:123e4567-e89b-12d3-a456-426655440222"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:123e4567-e89b-12d3-a456-426655440111", call_id: ^call_id, digits: "1"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:123e4567-e89b-12d3-a456-426655440222-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "123e4567-e89b-12d3-a456-426655440111", response: true, call_id: ^call_id, campaign_id: ^campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "answer negative symptom" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner) |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440111") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")
      {:ok, campaign: campaign, call: call, response: response}
    end

    test "it should advance current step" do
      assert %Call{current_step: "symptom:123e4567-e89b-12d3-a456-426655440222"} = Repo.one!(Call)
    end

    test "it should create a call log", %{call: %Call{id: call_id}} do
      assert %CallLog{step: "symptom:123e4567-e89b-12d3-a456-426655440111", call_id: ^call_id, digits: "3"} = (CallLog |> Query.last |> Repo.one!)
    end

    test "it should answer with symptom message", %{response: response} do
      assert {:gather, %{audio: "id-symptom:123e4567-e89b-12d3-a456-426655440222-es"}} = response
    end

    test "it should store answer for symptom", %{call: %Call{id: call_id, campaign_id: campaign_id}} do
      assert %CallAnswer{symptom: "123e4567-e89b-12d3-a456-426655440111", response: false, call_id: ^call_id, campaign_id: ^campaign_id} = (CallAnswer |> Query.last |> Repo.one!)
    end
  end

  describe "forwarding call on all symptoms" do
    setup do
      owner = build(:user) |> Repo.insert!
      campaign = build(:campaign, user: owner, forwarding_condition: "all") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440222") |> Repo.insert!
      build(:call_answer, symptom: "123e4567-e89b-12d3-a456-426655440111", response: true) |> for_call(call) |> Repo.insert!
      {:ok, campaign: campaign, call: call}
    end

    test "it should forward the call on all symptoms positive", %{campaign: campaign, call: call} do
      response = Flow.handle(campaign.id, call.sid, "1")

      assert %Call{current_step: "forward"} = Repo.one!(Call)
      assert {:forward, %{audio: "id-forward-es", number: "5550000"}} = response
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
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440222") |> Repo.insert!
      build(:call_answer, symptom: "123e4567-e89b-12d3-a456-426655440111", response: false) |> for_call(call) |> Repo.insert!
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
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440222") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "educational"} = Repo.one!(Call)
      assert {:play, %{audio: "id-educational-es"}} = response
    end

    test "it should skip educational message if disabled", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "zero") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440222") |> Repo.insert!
      response = Flow.handle(campaign.id, call.sid, "3")

      assert %Call{current_step: "thanks"} = Repo.one!(Call)
      assert {:hangup, %{audio: "id-thanks-es"}} = response
    end

    test "it should ask for confirmation if optional", %{owner: owner} do
      campaign = build(:campaign, user: owner, forwarding_condition: "any", additional_information: "optional") |> with_audios |> with_channel |> Repo.insert!
      call = build(:call, campaign: campaign, language: "es") |> on_step("symptom:123e4567-e89b-12d3-a456-426655440222") |> Repo.insert!
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
      response = Flow.handle(campaign.id, call.sid, nil)
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
