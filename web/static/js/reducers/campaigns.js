// @flow
import * as actions from '../actions/campaigns'
import collectionReducer, {defaultFilterProvider} from './collection'

const itemsReducer = (state: IndexedList<Campaign>, _): IndexedList<Campaign> => state

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

export default collectionReducer(actions, itemsReducer, defaultFilterProvider, initialState)
