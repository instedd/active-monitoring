// @flow
import * as api from '../api'
import type { GetState, Action, Dispatch } from '../types'
export const RECEIVE_TIMEZONES = 'RECEIVE_TIMEZONES'
export const FETCH_TIMEZONES = 'FETCH_TIMEZONES'

export const fetchTimezones = () => (dispatch: Dispatch, getState: GetState) => {
  const state = getState()
  if (state.timezones.fetching) {
    return
  }
  dispatch(startFetchingTimezones())

  return api
    .fetchTimezones()
    .then(response => { dispatch(receiveTimezones(response)) })
}

export const receiveTimezones = (timezones: string[]): Action => ({
  type: RECEIVE_TIMEZONES,
  timezones
})

export const startFetchingTimezones = (): Action => ({
  type: FETCH_TIMEZONES
})
