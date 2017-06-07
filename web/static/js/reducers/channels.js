// @flow
import * as actions from '../actions/channels'
import collectionReducer, {defaultFilterProvider} from './collection'

const itemsReducer = (state: IndexedList<Channel>, _): IndexedList<Channel> => state

const initialState = {
  fetching: false,
  items: null,
  filter: null,
  order: null,
  sortBy: 'name',
  sortAsc: false,
  page: {
    index: 0,
    size: 5
  }
}

export default collectionReducer(actions, itemsReducer, defaultFilterProvider, initialState)
