// @flow
import 'phoenix_html'

import React from 'react'
import { render } from 'react-dom'
import { createStore, applyMiddleware } from 'redux'
import { Provider } from 'react-redux'
import { Router, Route, Redirect, Switch } from 'react-router'
import createHistory from 'history/createBrowserHistory'
import { routerMiddleware } from 'react-router-redux'
import thunkMiddleware from 'redux-thunk'
import logger from 'redux-logger'

import reducers from './reducers'
import Nav from './components/Nav'
import Campaign from './components/campaigns/Campaign'
import Campaigns from './components/campaigns/Campaigns'
import Subjects from './components/subjects/Subjects'

const history = createHistory()

const store = createStore(
  reducers,
  applyMiddleware(
    thunkMiddleware,
    routerMiddleware(history),
    logger
  )
)

const root = document.getElementById('root')

if (root) {
  render(
    <Provider store={store}>
      <Router history={history}>
        <div className='react-container'>
          <Nav />
          <main>
            <div>
              <Switch>
                <Route exact path='/'>
                  <Redirect to='/campaigns' />
                </Route>

                <Route exact path='/campaigns' component={Campaigns} />
                <Route exact path='/campaigns/:id' component={Campaign} />
                <Route exact path='/campaigns/:campaignId/subjects' component={Subjects} />
              </Switch>
            </div>
          </main>
        </div>
      </Router>
    </Provider>,

    root
  )
}
