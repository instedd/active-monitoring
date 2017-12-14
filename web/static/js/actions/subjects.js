// @flow
import * as api from '../api'
import type { Items, Dispatch } from '../types'

export const RECEIVE = 'SUBJECTS_RECEIVE'
export const RECEIVE_ERROR = 'SUBJECTS_RECEIVE_ERROR'
export const FETCH = 'SUBJECTS_FETCH'
export const CHANGE_TARGET_PAGE = 'SUBJECTS_CHANGE_TARGET_PAGE'

export const changeTargetPage = (page: number) => (dispatch: Dispatch) => {
  dispatch(targetPage(page))
}

export const fetchSubjects = (campaignId: number, limit: number, page: number) => (dispatch: Dispatch) => {
  dispatch(startFetchingSubjects())
  return api.fetchSubjects(campaignId, limit, page)
    .then(response => dispatch(receiveSubjects(response || {}, limit, page)))
}

export const startFetchingSubjects = () => ({
  type: FETCH
})

export const targetPage = (page: number) => ({
  type: CHANGE_TARGET_PAGE,
  page
})

export const receiveSubjects = (items: Items, limit: number, page: number) => ({
  type: RECEIVE,
  items: items.subjects,
  count: items.count,
  limit,
  page
})
