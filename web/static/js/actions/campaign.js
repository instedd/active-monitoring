import * as api from '../api'
import { SERVER_ERROR } from './shared'
import { push } from 'react-router-redux'
import assign from 'lodash/assign'

export const CAMPAIGN_CREATE = 'CAMPAIGN_CREATE'
export const CAMPAIGN_CREATED = 'CAMPAIGN_CREATED'
export const CAMPAIGN_FETCH = 'CAMPAIGN_FETCH'
export const CAMPAIGN_FETCHED = 'CAMPAIGN_FETCHED'
export const CAMPAIGN_UPDATE = 'CAMPAIGN_UPDATE'
export const CAMPAIGN_UPDATED = 'CAMPAIGN_UPDATED'
export const CAMPAIGN_LAUNCH = 'CAMPAIGN_LAUNCH'

export const createCampaign = (campaignParams) => (dispatch) => {
  dispatch({type: CAMPAIGN_CREATE})
  const defaultProps = { symptoms: [], langs: [], name: '', audios: [] }
  const params = assign({}, defaultProps, campaignParams)

  api.createCampaign(params)
     .then((campaign) => {
       const campaignWithName = {...campaign, name: `Untitled Campaign #${campaign.id}`}
       dispatch(campaignCreated(campaignWithName))
       dispatch(campaignUpdate(campaignWithName))
       dispatch(push(`/campaigns/${campaignWithName.id}`))
     })
}

export const campaignCreated = (campaign) => {
  return { type: CAMPAIGN_CREATED, campaign }
}

export const campaignFetch = (id) => (dispatch) => {
  dispatch({type: CAMPAIGN_FETCH, id: id})

  api.fetchCampaign(id)
     .then((campaign) => {
       dispatch({ type: CAMPAIGN_FETCHED, campaign })
     })
}

export const campaignUpdate = (attrs) => (dispatch, getState) => {
  const newCampaign = assign({}, getState().campaign.data, attrs)

  dispatch({type: CAMPAIGN_UPDATED, campaign: newCampaign})
  api.updateCampaign(newCampaign)
    .catch((message) => {
      dispatch({type: SERVER_ERROR, message})
    })
}

export const campaignUpdated = (campaign) => {
  return { type: CAMPAIGN_UPDATED, campaign }
}

export const campaignLaunch = (id) => (dispatch) => {
  dispatch({type: CAMPAIGN_LAUNCH, id: id})

  api.launchCampaign(id)
     .then((campaign) => {
       dispatch({ type: CAMPAIGN_FETCHED, campaign })
     })
}
