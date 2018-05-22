defmodule ActiveMonitoring.BrokerTest do
  use ActiveMonitoring.ModelCase
  alias ActiveMonitoring.Runtime.{Broker}
  alias ActiveMonitoring.{Call, RespondentEmail}

  import Swoosh.TestAssertions

  describe "chat forwarding via e-mail" do
    setup [:campaign, :subject]

    test "no email is sent when there's no need to", %{campaign: campaign, subject: subject} do
      insert(:call, campaign: campaign, subject: subject, needs_to_be_forwarded: false, forwarded: false)

      Broker.handle_info(:notify, nil)

      assert Repo.one(Call).forwarded == false
      assert_no_email_sent()
    end

    test "email is sent when need to forward a non-forwarded call", %{campaign: campaign, subject: subject} do
      insert(:call, campaign: campaign, subject: subject, needs_to_be_forwarded: true, forwarded: false)

      Broker.handle_info(:notify, nil)

      assert Repo.one(Call).forwarded == true
      assert_email_sent RespondentEmail.positive_symptoms(campaign, subject)
    end

    test "no email is sent when call was already forwarded", %{campaign: campaign, subject: subject} do
      insert(:call, campaign: campaign, subject: subject, needs_to_be_forwarded: true, forwarded: true)

      Broker.handle_info(:notify, nil)

      assert Repo.one(Call).forwarded == true
      assert_no_email_sent()
    end
  end

  def campaign(_context) do
    [campaign: insert(:campaign, mode: "chat", forwarding_condition: "any")]
  end

  def subject(%{campaign: campaign}) do
    [subject: insert(:subject, campaign: campaign, contact_address: "Jane Doe")]
  end
end
