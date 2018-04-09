// @flow
import { connect } from 'react-redux'
import React, { Component, type Node } from 'react'
import { campaignUpdate } from '../../actions/campaign'
import TimezoneDropdown from '../timezones/TimeZoneDropdown'
import TextField from 'react-md/lib/TextFields'
import type { Campaign, Mode } from '../../types'

type Props = {
  campaign: Campaign,
  timezone: string,
  monitorDuration: number,
  onEditTimezone: (string) => void,
  onEditMonitorDuration: (string) => void,
  children: Node
}

class MonitoringSettingsComponent extends Component<Props> {
  intervalDescriptionCopy(mode: Mode): string {
    let copy = 'calls and call times'
    if (mode === 'chat') {
      copy = 'chat and chat times'
    }

    return copy
  }

  render() {
    const { campaign } = this.props

    return (
      <section id='monitoring' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Set up monitoring settings</h1>
            <p>
              Define the number of days on which care subjects will be
              monitored, the interval between {this.intervalDescriptionCopy(campaign.mode)}.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <TimezoneDropdown
              selected={campaign.timezone || ''}
              onEdit={this.props.onEditTimezone}
            />
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--3'>
            <TextField
              label='Duration'
              id='monitor-duration'
              value={campaign.monitorDuration || ''}
              type='number'
              min={0}
              step={1}
              onChange={this.props.onEditMonitorDuration}
              rightIcon={<span>days</span>}
            />
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            {this.props.children}
          </div>
        </div>
      </section>
    )
  }
}

const mapStateToProps = (state, ownProps) => {
  return {
    campaign: ownProps.campaign
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onEditTimezone: (timezone) => dispatch(campaignUpdate({timezone: timezone})),
    onEditMonitorDuration: (monitorDuration) => dispatch(campaignUpdate({monitorDuration: Number.parseInt(monitorDuration) || null}))
  }
}

const MonitoringSettingsStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(MonitoringSettingsComponent)

export default MonitoringSettingsStep
