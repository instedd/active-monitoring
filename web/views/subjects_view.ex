defmodule ActiveMonitoring.SubjectsView do
  use ActiveMonitoring.Web, :view
  alias ActiveMonitoring.{Subject}

  def render("index.json", %{subjects: subjects, count: count}) do
    rendered = subjects |> Enum.map(fn(subject) ->
      render_one(subject)
    end)
    %{
      data: %{subjects: rendered},
      meta: %{count: count}
    }
  end

  def render("show.json", %{subject: subject}) do
    %{data: render_one(subject)}
  end

  defp render_one(subject) do
    %{
      id: subject.id,
      campaign_id: subject.campaign_id,
      registration_identifier: subject.registration_identifier,
      contact_address: subject.contact_address,
      enroll_date: Subject.enroll_date(subject),
      first_call_date: Subject.first_call_date(subject),
      last_call_date: Subject.last_call_date(subject),
      last_successful_call_date: Subject.last_successful_call_date(subject),
      active_case: Subject.active_case(subject),
    }
  end
end
