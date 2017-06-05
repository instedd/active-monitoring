import {combineReducers} from 'redux'
import {routerReducer} from 'react-router-redux'
import campaign from './campaign'
import campaigns from './campaigns'

export default combineReducers({
  campaign,
  campaigns,
  router: routerReducer
})
