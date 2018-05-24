# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ActiveMonitoring.Repo.insert!(%ActiveMonitoring.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ActiveMonitoring.{Repo, Call, Subject, CallAnswer, Campaign}

symptoms = [["1", "Fever"],["2","Rash"]]
campaign = Repo.insert!(%Campaign{
  name: "Campaign Seed",
  symptoms: symptoms,
  forwarding_condition: "any",
  forwarding_address: "12345678",
  mode: "call",
  langs: ["en"],
  additional_information: "zero",
  started_at: Ecto.DateTime.utc()
})

subjects = [
  Repo.insert!(%Subject{contact_address: "123456781", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456782", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456783", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456784", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456785", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456786", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456787", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456788", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456789", campaign_id: campaign.id}),
  Repo.insert!(%Subject{contact_address: "123456780", campaign_id: campaign.id}),
]


for i <- 1..30 do
  step = Enum.random(["welcome","thanks"])
  call = Repo.insert!(%Call{
      sid: "SID_#{i}",
      language: "en",
      campaign_id: campaign.id,
      current_step: step,
      subject_id: Enum.random(subjects).id
    })
  if step == "thanks" do
    Repo.insert!(%CallAnswer{campaign_id: campaign.id, call_id: call.id, symptom: "1", response: Enum.random([true, false])})
    Repo.insert!(%CallAnswer{campaign_id: campaign.id, call_id: call.id, symptom: "2", response: Enum.random([true, false])})
  end
end
