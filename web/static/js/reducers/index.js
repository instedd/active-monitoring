import {combineReducers} from 'redux'
import {routerReducer} from 'react-router-redux'
import campaign from './campaign'
import campaigns from './campaigns'
import channels from './channels'
import authorizations from './authorizations'

export default combineReducers({
  campaign,
  campaigns,
  channels,
  authorizations,
  router: routerReducer
})
