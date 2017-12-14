defmodule ActiveMonitoring.SubjectsView do
  use ActiveMonitoring.Web, :view

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
      phone_number: subject.phone_number,
    }
  end
end
