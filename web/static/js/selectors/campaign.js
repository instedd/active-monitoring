export const audioEntries = (state) => {
  const langs = state.campaign.data.langs || []
  const symptoms = (state.campaign.data.symptoms || []).map(([id, name]) => `symptom:${id}`)
  let topics = ['welcome'].concat(symptoms).concat(['forward', 'educational', 'thanks'])
  if (state.campaign.data.additionalInformation != 'compulsory' && state.campaign.data.additionalInformation != 'optional') {
    const i = topics.indexOf('educational')
    topics.splice(i, 1)
  }

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
