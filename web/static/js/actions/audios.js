import { createAudio } from '../api.js'
import { campaignUpdate } from './campaign.js'

import reject from 'lodash/reject'

export const CAMPAIGN_AUDIO_UPLOADED = 'CAMPAIGN_AUDIO_UPLOADED'

export const campaignAudioUploaded = (audioId, topic, language) => {
  return { type: CAMPAIGN_AUDIO_UPLOADED, audio: audioId, topic: topic, language: language }
}

const removeAudio = (topic, language, audios) => {
  return reject(audios, ([_topic, _language, _uuid]) => (topic == _topic && language == _language))
}

const mergeAudio = (id, topic, language, audios) => {
  let updatedAudios = removeAudio(topic, language, audios)
  return [...updatedAudios, [topic, language, id]]
}

export const uploadCampaignAudio = (file, topic, language) => (dispatch, getState) => {
  createAudio(file).then(response => {
    dispatch(campaignAudioUploaded(response.id, topic, language))
    const updatedAudios = mergeAudio(response.id, topic, language, getState().campaign.data.audios)
    dispatch(campaignUpdate({audios: updatedAudios}))
  })
}

export const removeCampaignAudio = (topic, language) => (dispatch, getState) => {
  const updatedAudios = removeAudio(topic, language, getState().campaign.data.audios)
  dispatch(campaignUpdate({audios: updatedAudios}))
}
