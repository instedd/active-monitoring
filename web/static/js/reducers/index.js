import {combineReducers} from 'redux'
import {routerReducer} from 'react-router-redux'
import campaigns from './campaigns'

export default combineReducers({
  campaigns,
  router: routerReducer
})
