// @flow
import * as api from '../api'
import { SERVER_ERROR } from './shared'
import assign from 'lodash/assign'
import type { SubjectParams, Subject, Dispatch, GetState } from '../types'

export const SUBJECT_CREATE = 'SUBJECT_CREATE'
export const SUBJECT_CREATED = 'SUBJECT_CREATED'
export const SUBJECT_FETCH = 'SUBJECT_FETCH'
export const SUBJECT_FETCHED = 'SUBJECT_FETCHED'
export const SUBJECT_EDIT = 'SUBJECT_EDIT'
export const SUBJECT_EDITING = 'SUBJECT_EDITING'
export const SUBJECT_UPDATE = 'SUBJECT_UPDATE'
export const SUBJECT_UPDATED = 'SUBJECT_UPDATED'
export const SUBJECT_LAUNCH = 'SUBJECT_LAUNCH'

export const createSubject = (campaignId: number, subjectParams: SubjectParams) => (dispatch: Dispatch) => {
  dispatch({type: SUBJECT_CREATE})
  const defaultProps = { }
  const params = assign({}, defaultProps, subjectParams)

  api.createSubject(campaignId, params)
     .then((subject) => {
       dispatch(subjectCreated(subject))
     })
}

export const editingSubjectCancel = () => {
  return { type: SUBJECT_EDIT, subject: null }
}

export const editSubject = (subject: Subject) => {
  return { type: SUBJECT_EDIT, subject }
}

export const subjectEditing = (fieldName: string, value: string) => (
  { type: SUBJECT_EDITING, fieldName, value }
)

export const subjectCreated = (subject: Subject) => {
  return { type: SUBJECT_CREATED, subject }
}

export const subjectFetch = (id: number) => (dispatch: Dispatch) => {
  dispatch({type: SUBJECT_FETCH, id: id})

  api.fetchSubject(id)
    .then((subject) => {
      dispatch({ type: SUBJECT_FETCHED, subject: subject })
    })
}

export const updateSubject = (campaignId: number, subjectParams: SubjectParams) => (dispatch: Dispatch, getState: GetState) => {
  const newSubject = assign({}, getState().subjects.editingSubject, subjectParams)

  api.updateSubject(campaignId, newSubject)
    .then((subject) => {
      dispatch({ type: SUBJECT_UPDATED, subject })
    })
    .catch((message) => {
      dispatch({type: SERVER_ERROR, message})
    })
}

export const subjectUpdated = (subject: Subject) => {
  return { type: SUBJECT_UPDATED, subject }
}
