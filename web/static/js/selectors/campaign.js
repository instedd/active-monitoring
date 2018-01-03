// @flow
import type { Campaign, Audio } from '../types'

export const audioEntries = (campaign: Campaign): { [lang: string]: string[] } => {
  const langs = campaign.langs.filter((lang) => lang && lang != '')

  const symptoms = (campaign.symptoms || []).filter(([id, name]) => name && name != '').map(([id, name]) => `symptom:${id}`)
  let topics = ['welcome', 'identify', 'registration'].concat(symptoms).concat(['forward', 'additional_information_intro', 'educational', 'thanks'])
  if (campaign.additionalInformation == 'zero' || campaign.additionalInformation == undefined) {
    const i = topics.indexOf('additional_information_intro')
    topics.splice(i, 2)
  }
  if (campaign.additionalInformation == 'compulsory') {
    const i = topics.indexOf('additional_information_intro')
    topics.splice(i, 1)
  }

  const entries = {}
  langs.forEach((lang) => {
    entries[lang] = topics.slice()
  })

  return entries
}

export const audiosInUse = (campaign: Campaign): Audio[] => {
  const entries = audioEntries(campaign)
  let inUse : Audio[] = []
  const welcomeAudio = campaign.audios.find((audio) => audio[0] == 'language' && audio[1] == null)
  if (welcomeAudio) {
    inUse.push(welcomeAudio)
  }
  for (const language in entries) {
    const steps = entries[language]
    steps.forEach((step) => {
      const audio = campaign.audios.find((audio) => audio[0] == step && audio[1] == language)
      if (audio) {
        inUse.push(audio)
      }
    })
  }
  return inUse
}

export const getAudioFileFor = (audios: Audio[], topic: string, language: string) => {
  const audio = audios.find(([_topic, _language, _uuid]) => (topic == _topic && language == _language))
  return audio && audio[2] // uuid
}
