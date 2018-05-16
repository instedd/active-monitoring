import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Paper, List, ListItem, FontIcon, Divider } from 'react-md'
import 'react-vis/dist/styles/legends.scss'
import {
  XYPlot,
  XAxis,
  YAxis,
  HorizontalGridLines,
  VerticalBarSeries,
  DiscreteColorLegend,
  LineSeries,
  makeVisFlexible
} from 'react-vis'

const FlexibleXYPlot = makeVisFlexible(XYPlot)

var weekOfYear = function(date) {
  if (!date) { date = Date() }
  var d = new Date(date)
  d.setHours(0, 0, 0)
  d.setDate(d.getDate() + 4 - (d.getDay() || 7))
  return Math.ceil((((d - new Date(d.getFullYear(), 0, 1)) / 8.64e7) + 1) / 7)
}

export default class CampaignDashboard extends Component {
  render() {
    const { campaign, subjectStats, callStats } = this.props

    let weeksInChart = []
    let currentWeek = weekOfYear()
    for (var i = 12; i > 0; i--) {
      weeksInChart.push(currentWeek - i)
    }

    let actionTitle = ''
    if (campaign.mode === 'call') {
      actionTitle = 'Calls'
    } else if (campaign.mode === 'chat') {
      actionTitle = 'Chats'
    }

    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>Campaign performance</h3>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--3 dashboard-data'>
            <div className='md-grid'>
              <List className='md-cell md-cell--8'>
                <ListItem
                  rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>}
                  primaryText={subjectStats.cases}
                  secondaryText='Cases detected'
                  className='red-text' />
                <ListItem
                  rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>}
                  primaryText={subjectStats.totalSubjects}
                  secondaryText='Subjects' />
              </List>
            </div>
          </div>
          <div className='md-cell md-cell--9 dashboard-chart'>
            <Paper zDepth={2} className='white rounded-corners' >
              <h2>Weekly enrolled Subjects</h2>
              <div id='chart'>
                <FlexibleXYPlot
                  xType='ordinal'
                  xDistance={100}
                  stackBy='y'>
                  <HorizontalGridLines
                    style={{'stroke': '#E4E4E4'}}
                    left={12} />
                  <XAxis style={{text: {stroke: 'none', fill: '#A4A4A4', fontSize: 12, top: 4}}} />
                  <YAxis style={{text: {stroke: 'none', fill: '#A4A4A4', fontSize: 12, top: 4}}}
                    top={20} />
                  <LineSeries
                    data={subjectStats.timeline}
                    color='#4FAF54' />
                </FlexibleXYPlot>
              </div>
            </Paper>
          </div>
        </div>
        <Divider className='dashboard-divider' />
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>{actionTitle} performance</h3>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--3 dashboard-data'>
            <div className='md-grid'>
              <List className='md-cell md-cell--8'>
                <ListItem
                  rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>}
                  primaryText={callStats.today}
                  secondaryText={`${actionTitle} today`} />
                <ListItem
                  rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>}
                  primaryText={callStats.lastWeek}
                  secondaryText={`${actionTitle} last 7 days`} />
                <ListItem
                  rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>}
                  primaryText={callStats.successfulOverall}
                  secondaryText={`Successful ${actionTitle}`} />
              </List>
            </div>
          </div>
          <div className='md-cell md-cell--9 dashboard-chart'>
            <Paper zDepth={2} className='white rounded-corners'>
              <h2>Weekly {actionTitle} by status</h2>
              <DiscreteColorLegend
                orientation='horizontal'
                items={[{title: 'Successful', color: '#4FAF54'}, {title: 'Partial', color: '#FEC12E'}]} />
              <div id='chart'>
                <FlexibleXYPlot
                  xType='ordinal'
                  xDistance={100}
                  stackBy='y'>
                  <HorizontalGridLines
                    style={{'stroke': '#E4E4E4'}}
                    left={12} />
                  <XAxis style={{text: {stroke: 'none', fill: '#A4A4A4', fontSize: 12, top: 4}}} />
                  <YAxis style={{text: {stroke: 'none', fill: '#A4A4A4', fontSize: 12, top: 4}}}
                    top={20} />
                  <VerticalBarSeries
                    className='success'
                    data={callStats.timeline[0]}
                    color='#4FAF54' />
                  <VerticalBarSeries
                    className='partial'
                    data={callStats.timeline[0]}
                    color='#FEC12E' />
                </FlexibleXYPlot>
              </div>
            </Paper>
          </div>
        </div>
      </div>
    )
  }
}
CampaignDashboard.propTypes = {
  callStats: PropTypes.object,
  subjectStats: PropTypes.object,
  campaign: PropTypes.object
}
