// @flow weak
import * as actions from '../actions/timezones'

const initialState = {
  fetching: false,
  items: null
}

export default (state = initialState, action) => {
  switch (action.type) {
    case actions.FETCH_TIMEZONES: return fetchTimezones(state)
    case actions.RECEIVE_TIMEZONES: return receiveTimezones(state, action)
    default: return state
  }
}

const fetchTimezones = (state) => ({
  ...state,
  fetching: true
})

const receiveTimezones = (state, action) => {
  return {
    ...state,
    fetching: false,
    items: action.timezones
  }
}
