import * as actions from '../actions/subjects'
import * as itemActions from '../actions/subject'

const initialState = {
  editingSubject: null,
  fetching: false,
  items: null,
  count: 0,
  filter: null,
  order: null,
  limit: 50,
  page: null,
  targetPage: 1
}

const subjectEdit = (state, editingSubject) => (
  {
    ...state,
    editingSubject
  }
)

const subjectEditing = (state, fieldName, value) => (
  {
    ...state,
    editingSubject: {
      ...state.editingSubject,
      [fieldName]: value
    }
  }
)

const subjectCreated = (state, subject) => (
  {
    ...state,
    editingSubject: null,
    items: [...state.items, subject],
    count: state.count + 1
  }
)

const subjectUpdated = (state, subject) => {
  const index = state.items.findIndex(item => item.id == subject.id)
  return {
    ...state,
    editingSubject: null,
    items: [
      ...state.items.slice(0, index),
      subject,
      ...state.items.slice(index + 1)
    ]
  }
}

const receive = (state, items, count, limit, page) => (
  {
    ...state,
    fetching: false,
    items,
    count,
    limit,
    page
  }
)

const fetch = (state) => (
  {
    ...state,
    fetching: true
  }
)

const changeTargetPage = (state, targetPage) => (
  {
    ...state,
    targetPage
  }
)

export default (state, action) => {
  switch (action.type) {
    case itemActions.SUBJECT_EDIT: return subjectEdit(state, action.subject)
    case itemActions.SUBJECT_EDITING: return subjectEditing(state, action.fieldName, action.value)
    case itemActions.SUBJECT_CREATED: return subjectCreated(state, action.subject)
    case itemActions.SUBJECT_UPDATED: return subjectUpdated(state, action.subject)
    case actions.FETCH: return fetch(state)
    case actions.RECEIVE: return receive(state, action.items, action.count, action.limit, action.page)
    case actions.CHANGE_TARGET_PAGE: return changeTargetPage(state, action.page)
    default: return state || initialState
  }
}
