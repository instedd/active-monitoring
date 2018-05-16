import { campaignUpdate } from './campaign.js'

import reject from 'lodash/reject'

const removeChatText = (topic, language, chatTexts) => {
  return reject(chatTexts, ([_topic, _language]) => (topic == _topic && language == _language))
}

const mergeChatText = (text, topic, language, chatTexts) => {
  let updatedChatTexts = removeChatText(topic, language, chatTexts)
  return [...updatedChatTexts, [topic, language, text]]
}

export const editCampaignChatText = (text, topic, language) => (dispatch, getState) => {
  const updatedChatTexts = mergeChatText(text, topic, language, getState().campaign.data.chatTexts)
  dispatch(campaignUpdate({ chatTexts: updatedChatTexts }))
}
