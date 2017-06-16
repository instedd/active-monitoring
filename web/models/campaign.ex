defmodule ActiveMonitoring.Campaign do
  use ActiveMonitoring.Web, :model

  schema "campaigns" do
    field :name, :string
    field :symptoms, {:array, {:array, :string}} # [{id, label}]
    field :forwarding_condition, :string
    field :forwarding_number, :string
    field :audios, {:array, {:array, :string}} # [{(symptom:id|language|welcome|thanks), lang?, audio.uuid}]
    field :langs, {:array, :string}
    # field :additional_information, :string
    # field :alert_recipients, {:array, :string}
    # field :additional_fields, {:array, :string}

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:name, :symptoms, :forwarding_number, :forwarding_condition, :audios, :langs])
  end
end
