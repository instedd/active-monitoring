export const audioEntries = (state) => {
  const langs = ['en', 'es']
  const symptoms = (state.campaign.data.symptoms || []).map(([id, name]) => `symptom:${id}`)
  const topics = ['welcome'].concat(symptoms).concat(['forward', 'educational', 'thanks'])

  const entries = {}
  langs.forEach((lang) => {
    entries[lang] = topics.slice()
  })

  return entries
}

export const getAudioFileFor = (audios, topic, language) => {
  const audio = audios.find(([_topic, _language, _uuid]) => (topic == _topic && language == _language))
  return audio && audio[2] // uuid
}
