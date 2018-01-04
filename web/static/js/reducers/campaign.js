import * as actions from '../actions/campaign'
import * as symptomActions from '../actions/symptoms'
import * as languageActions from '../actions/langs'
import uuid from 'uuid/v4'

const initialState = {
  fetching: false,
  campaignId: null,
  data: null
}

export default (state = initialState, action) => {
  switch (action.type) {
    case actions.CAMPAIGN_CLEAR: return campaignClear(state, action)
    case actions.CAMPAIGN_CREATED: return campaignLoaded(state, action)
    case actions.CAMPAIGN_FETCH: return campaignFetch(state, action)
    case actions.CAMPAIGN_FETCHED: return campaignLoaded(state, action)
    case actions.CAMPAIGN_UPDATED: return campaignLoaded(state, action)
    case symptomActions.EMPTY_SYMPTOM_ADD: return addEmptySymptom(state)
    case languageActions.EMPTY_LANG_ADD: return addEmptyLang(state)
    case actions.CAMPAIGN_LAUNCH: return launchCampaign(state)
    default: return state
  }
}

const campaignClear = (state) => (
  { fetching: false, campaignId: null, data: null }
)

const campaignFetch = (state, id) => {
  return { fetching: true, campaignId: id, data: null }
}

const campaignLoaded = (state, { campaign, calls }) => {
  return { fetching: false, campaignId: campaign.id, data: campaign }
}

const addEmptySymptom = (state) => {
  let symptoms = state.data.symptoms || []
  return { ...state, data: { ...state.data, symptoms: [...symptoms, [uuid(), '']] } }
}

const addEmptyLang = (state) => {
  let langs = state.data.langs || []
  return { ...state, data: { ...state.data, langs: [...langs, ''] } }
}

const launchCampaign = (state) => {
  return { ...state, data: { ...state.data, started_at: new Date() } }
}
