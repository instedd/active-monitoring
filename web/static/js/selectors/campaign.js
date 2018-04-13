// @flow
import type { Campaign, LanguageCode } from '../types'
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

export const messagesInUse = (campaign: Campaign): [] => {
  const entries = neededMessages(campaign)

  let inUse = []

  let messages = campaign.audios
  if (campaign.mode == 'chat') {
    messages = campaign.chatTexts
  }

  const welcomeMessage = messages.find((msg) => msg[0] == 'language' && msg[1] == '')
  if (welcomeMessage && welcomeMessage[2] != '') {
    inUse.push(welcomeMessage)
  }

  for (const language in entries) {
    const steps = entries[language]
    steps.forEach((step) => {
      const msg = messages.find((msg) => msg[0] == step && msg[1] == language)
      if (msg && msg[2] != '') {
        inUse.push(msg)
      }
    })
  }

  return inUse
}

export const getAudioFileFor = (messages: string[][], step: string, language: ?LanguageCode): string | void => {
  const audio = messages.find(([_topic, _language, _uuid]) => (step == _topic && language == _language))
  return audio && audio[2]
}

export const getChatTextFor = (messages: string[][], step: string, language: ?LanguageCode): string | void => {
  const chatMessage = messages.find(([_topic, _language, _text]) => (step == _topic && language == _language))
  return chatMessage && chatMessage[2]
}

export const completedMessages = (campaign: Campaign): boolean => {
  const uploadedMessages = messagesInUse(campaign).length
  const necessaryMessages = flatten(values(neededMessages(campaign))).length + 1
  return (uploadedMessages > 1) && (uploadedMessages === necessaryMessages)
}
