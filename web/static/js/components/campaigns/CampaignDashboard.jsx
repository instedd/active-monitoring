import React, { Component } from 'react'
// import PropTypes from 'prop-types'
import Paper from 'react-md/lib/Papers'

export default class CampaignCreationForm extends Component {
  render() {
    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>Campaign performance</h3>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--2'>
            17
          </div>
          <div className='md-cell md-cell--10'>
            <Paper zDepth={2}>
              Chart
            </Paper>
          </div>
        </div>
      </div>
    )
  }
}
