import * as actions from '../actions/campaigns'
import collectionReducer, {defaultFilterProvider} from './collection'

const itemsReducer = (state) => state

const initialState = {
  fetching: false,
  items: null,
  filter: null,
  order: null,
  sortBy: 'updated_at',
  sortAsc: false,
  page: {
    index: 0,
    size: 5
  }
}

export const isActive = (campaign) => {
  return campaign.startedAt !== null
}

export const activeCampaignUsing = (campaigns) => (channelName) => {
  return campaigns.items.find((campaign) => isActive(campaign) && campaign.channel === channelName)
}

export default collectionReducer(actions, itemsReducer, defaultFilterProvider, initialState)
