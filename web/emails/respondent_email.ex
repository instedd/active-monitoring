Code.ensure_loaded Phoenix.Swoosh

defmodule ActiveMonitoring.RespondentEmail do
  use Phoenix.Swoosh, view: ActiveMonitoring.EmailView
  alias Coherence.Config

  def positive_symptoms(%{forwarding_address: forwarding_address}, %{contact_address: contact_address, registration_identifier: registration_identifier}) do
    new()
    |> from({Config.email_from_name, Config.email_from_email})
    |> to(forwarding_address)
    |> subject("Alert: Positive symptoms detected for #{contact_address}")
    |> render_body(:positive_symptoms, %{
        forwarding_address: forwarding_address,
        contact_address: contact_address,
        registration_identifier: registration_identifier
      })
  end
end
