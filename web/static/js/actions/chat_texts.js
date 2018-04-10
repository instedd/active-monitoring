import { createChatText } from '../api.js'
import { campaignUpdate } from './campaign.js'

import reject from 'lodash/reject'

export const CAMPAIGN_CHAT_TEXT_ADDED = 'CAMPAIGN_CHAT_TEXT_ADDED'

export const campaignChatTextAdded = (chatTextId, topic, language) => {
  return { type: CAMPAIGN_CHAT_TEXT_ADDED, chat_text: chatTextId, topic: topic, language: language }
}

const removeChatText = (topic, language, chatTexts) => {
  return reject(chatTexts, ([_topic, _language, _id]) => (topic == _topic && language == _language))
}

const mergeChatText = (id, topic, language, chatTexts) => {
  let updatedChatTexts = removeChatText(topic, language, chatTexts)
  return [...updatedChatTexts, [topic, language, id]]
}

export const addCampaignChatText = (text, topic, language) => (dispatch, getState) => {
  createChatText(text).then(response => {
    dispatch(campaignChatTextAdded(response.id, topic, language))
    const updatedChatTexts = mergeChatText(response.id, topic, language, getState().campaign.data.chat_texts)
    dispatch(campaignUpdate({ chat_texts: updatedChatTexts }))
  })
}

export const removeCampaignChatText = (topic, language) => (dispatch, getState) => {
  const updatedChatTexts = removeChatText(topic, language, getState().campaign.data.chat_texts)
  dispatch(campaignUpdate({ chat_texts: updatedChatTexts }))
}
