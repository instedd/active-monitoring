defmodule ActiveMonitoring.CallAnswer do
  use ActiveMonitoring.Web, :model

  alias ActiveMonitoring.{Repo, Campaign, Call}

  schema "call_answers" do
    field :symptom, :string
    field :response, :boolean

    belongs_to :call, Call
    belongs_to :campaign, Campaign

    timestamps(updated_at: false)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:symptom, :response, :call_id, :campaign_id])
  end
end
