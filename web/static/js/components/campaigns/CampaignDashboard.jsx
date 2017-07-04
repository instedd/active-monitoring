import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Paper from 'react-md/lib/Papers'
import 'react-vis/dist/styles/radial-chart.scss'
import {
  XYPlot,
  XAxis,
  YAxis,
  HorizontalGridLines,
  VerticalBarSeries
} from 'react-vis'

export default class CampaignDashboard extends Component {
  render() {
    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>Calls performance</h3>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--2'>
            <div className='md-grid'>
              <div className='md-cell'>{this.props.call_stats.today} Calls today</div>
              <div className='md-cell'>{this.props.call_stats.lastWeek} Calls in the last 7 days</div>
              <div className='md-cell'>{this.props.call_stats.successfulOverall} Successful calls</div>
            </div>
          </div>
          <div className='md-cell md-cell--10'>
            <Paper zDepth={2}>
              <XYPlot
                xType='ordinal'
                width={300}
                height={300}
                xDistance={100}
                stackBy='y'>
                <HorizontalGridLines />
                <XAxis />
                <YAxis />
                <VerticalBarSeries
                  className='vertical-bar-series-example'
                  data={[
                    {x: 'A', y: 10},
                    {x: 'B', y: 5},
                    {x: 'C', y: 15}
                  ]} />
                <VerticalBarSeries
                  data={[
                    {x: 'A', y: 12},
                    {x: 'B', y: 2},
                    {x: 'C', y: 11}
                  ]} />
              </XYPlot>
            </Paper>
          </div>
        </div>
      </div>
    )
  }
}

CampaignDashboard.propTypes = {
  call_stats: PropTypes.object
}
