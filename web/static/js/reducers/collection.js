import isEqual from 'lodash/isEqual'
import values from 'lodash/values'

export const defaultFilterProvider = (_) => ({})

export default (actions, itemsReducer, filterProvider, initialState) => (state, action) => {
  state = state || initialState
  switch (action.type) {
    case actions.FETCH: return fetch(state, action, filterProvider)
    case actions.RECEIVE: return receive(state, action, filterProvider)
    case actions.NEXT_PAGE: return nextPage(state)
    case actions.PREVIOUS_PAGE: return previousPage(state)
    case actions.SORT: return sortItems(state, action)
    default: return items(state, action, itemsReducer)
  }
}

const items = (state, action, itemsReducer) => {
  const newItems = state.items == null ? null : itemsReducer(state.items, action)

  if (newItems !== state.items) {
    let order = itemsOrder(newItems, state.sortBy, state.sortAsc)
    return ({
      ...state,
      items: newItems,
      order
    })
  }

  return state
}

const receive = (state, action, filterProvider) => {
  const itemsFilter = filterProvider(action)

  if (isEqual(state.filter, itemsFilter)) {
    const items = action.items
    let order = itemsOrder(items, state.sortBy, state.sortAsc)
    return {
      ...state,
      fetching: false,
      items: items,
      order
    }
  }

  return state
}

const fetch = (state, action, filterProvider) => {
  const newFilter = filterProvider(action)

  let newItems = null

  if (isEqual(state.filter, newFilter)) {
    newItems = state.items
  }

  return {
    ...state,
    fetching: true,
    filter: newFilter,
    items: newItems,
    page: {
      ...state.page,
      index: 0
    }
  }
}

const itemsOrder = (items, sortBy, sortAsc) => {
  const itemsValues = values(items)

  if (sortBy) {
    itemsValues.sort((p1, p2) => {
      let x1 = p1[sortBy]
      let x2 = p2[sortBy]

      if (typeof (x1) == 'string') {
        x1 = x1.toLowerCase()
        if (x2 == null) x2 = 'untitled'
      }
      if (typeof (x2) == 'string') {
        x2 = x2.toLowerCase()
        if (x1 == null) x1 = 'untitled'
      }

      if (x1 < x2) {
        return sortAsc ? -1 : 1
      } else if (x1 > x2) {
        return sortAsc ? 1 : -1
      } else {
        return 0
      }
    })
  }

  return itemsValues.map(p => p.id)
}

const sortItems = (state, action) => {
  const sortAsc = state.sortBy == action.property ? !state.sortAsc : true
  const sortBy = action.property
  const order = itemsOrder(state.items, sortBy, sortAsc)
  return {
    ...state,
    order,
    sortBy,
    sortAsc
  }
}

const nextPage = (state) => ({
  ...state,
  page: {
    ...state.page,
    index: state.page.index + state.page.size
  }
})

const previousPage = (state) => ({
  ...state,
  page: {
    ...state.page,
    index: state.page.index - state.page.size
  }
})

export const orderedItems = (items, order) => {
  if (items && order) {
    return order.map(id => items[id])
  } else {
    return null
  }
}
