import * as api from '../api'

export const RECEIVE = 'CHANNELS_RECEIVE'
export const RECEIVE_ERROR = 'CHANNELS_RECEIVE_ERROR'
export const FETCH = 'CHANNELS_FETCH'

export const fetchChannels = () => (dispatch, getState) => {
  const state = getState()

  if (state.channels.fetching) {
    return
  }

  dispatch(startFetchingChannels())
  return api.fetchChannels()
    .then(response => dispatch(receiveChannels(response || {})))
}

export const startFetchingChannels = () => ({
  type: FETCH
})

export const receiveChannels = (items) => ({
  type: RECEIVE,
  items
})
