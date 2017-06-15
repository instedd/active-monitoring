import { createAudio } from '../api.js'

export const CAMPAIGN_AUDIO_UPLOADED = 'CAMPAIGN_AUDIO_UPLOADED'

export const campaignAudioUploaded = (audioId, topic, language) => {
  return { type: CAMPAIGN_AUDIO_UPLOADED, audio: audioId, topic: topic, language: language }
}

export const uploadCampaignAudio = (file, topic, language) => (dispatch, getState) => {
  createAudio(file).then(response => {
    dispatch(campaignAudioUploaded(response.id, topic, language))
  })
}
