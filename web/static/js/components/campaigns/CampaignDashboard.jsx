import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Paper, List, ListItem, FontIcon, Divider } from 'react-md'
import TextField from 'react-md/lib/TextFields'
import Button from 'react-md/lib/Buttons/Button'
import Card from 'react-md/lib/Cards/Card'
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
  openFbPageInfo() {
    window.open('https://www.facebook.com/business/products/pages')
  }

  openFbBotInfo() {
    window.open('https://developers.facebook.com/docs/messenger-platform/getting-started/app-setup')
  }

  render() {
    const { campaign, subjectStats, callStats } = this.props

    let weeksInChart = []
    let currentWeek = weekOfYear()
    for (var i = 12; i > 0; i--) {
      weeksInChart.push(currentWeek - i)
    }

    let actionTitle = ''
    let facebookSetupInfoComponent = null
    if (campaign.mode === 'call') {
      actionTitle = 'Calls'
    } else if (campaign.mode === 'chat') {
      actionTitle = 'Chats'
      if (subjectStats.totalSubjects == 0) {
        facebookSetupInfoComponent = (<Card>
          <div className='md-grid'>
            <div className='md-cell md-cell--6'>
              <h3>Setup a Facebook channel</h3>
              <p>
                Before the campaign can start you need to create Facebook page and then subscribe a bot.
              </p>
              <p>
                Note: This message will disappear when you create a Subject.
              </p>

              <Button flat primary label='Read about How to create a Facebook Page' onClick={this.openFbPageInfo}>info</Button>
              <Button flat primary label='Read about How to subscribe a Facebook Bot' onClick={this.openFbBotInfo}>info</Button>
              <TextField
                label='Facebook Callback URL'
                id='facebook-callback-url'
                value={`${location.protocol}//${location.host}/callback/facebook`}
                readOnly
              />
              <TextField
                label='Facebook Page Id'
                id='fb-page-id'
                value={campaign.fbPageId}
                readOnly
              />
              <TextField
                label='Verify Token'
                id='fb-verify-token'
                value={campaign.fbVerifyToken}
                readOnly
              />
              <TextField
                label='Access Token'
                id='fb-access-token'
                value={campaign.fbAccessToken}
                readOnly
              />
            </div>
          </div>
        </Card>)
      }
    }

    return (
      <div>
        {facebookSetupInfoComponent}
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
