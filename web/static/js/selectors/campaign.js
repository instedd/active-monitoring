// @flow
import type { Campaign, LanguageCode, Message } from '../types'
import values from 'lodash/values'
import flatten from 'lodash/flatten'

export const neededMessages = (campaign: Campaign): { [lang: string]: string[] } => {
  const symptoms = (campaign.symptoms || [])
    .filter(([id, name]) => name && name != '')
    .map(([id, name]) => `symptom:${id}`)

  let topics = ['welcome', 'identify', 'registration']
    .concat(symptoms)
    .concat(['forward', 'additional_information_intro', 'educational', 'thanks'])

  if (campaign.additionalInformation == 'zero' || campaign.additionalInformation == undefined) {
    const i = topics.indexOf('additional_information_intro')
    topics.splice(i, 2)
  }

  if (campaign.additionalInformation == 'compulsory') {
    const i = topics.indexOf('additional_information_intro')
    topics.splice(i, 1)
  }

  const entries = {}

  const langs = campaign.langs.filter((lang) => lang && lang != '')
  langs.forEach((lang) => {
    entries[lang] = topics.slice()
  })

  return entries
}

export const messagesInUse = (campaign: Campaign): Message[] => {
  const entries = neededMessages(campaign)

  let inUse : Message[] = []

  const welcomeMessage = campaign.messages.find((msg) => msg.step == 'language' && msg.language == null && msg.mode === campaign.mode)
  if (welcomeMessage) {
    inUse.push(welcomeMessage)
  }

  for (const language in entries) {
    const steps = entries[language]
    steps.forEach((step) => {
      const msg = campaign.messages.find((msg) => campaign.mode === msg.mode && msg.step == step && msg.language == language)
      if (msg) {
        inUse.push(msg)
      }
    })
  }
  return inUse
}

export const getAudioFileFor = (messages: Message[], step: string, language: ?LanguageCode): string | void => {
  const audio = messages.find((msg) => (step == msg.step && language == msg.language && msg.mode === 'call'))
  return audio && audio.value
}

export const completedMessages = (campaign: Campaign): boolean => {
  const uploadedMessages = messagesInUse(campaign).length
  const necessaryMessages = flatten(values(neededMessages(campaign))).length + 1
  return (uploadedMessages > 1) && (uploadedMessages === necessaryMessages)
}
