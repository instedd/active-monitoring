import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { campaignUpdate } from '../../actions/campaign'
import TimezoneDropdown from '../timezones/TimeZoneDropdown'
import TextField from 'react-md/lib/TextFields'

class MonitoringSettingsComponent extends Component {
  render() {
    return (
      <section id='monitoring'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Set up monitoring settings</h1>
            <p>
              Define the number of days on which care subjects will be monitored, the interval between calls and call times.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <TimezoneDropdown selected={this.props.timezone} onEdit={this.props.onEditTimezone} />
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--3'>
            <TextField label='Duration' id='monitor-duration' value={this.props.monitorDuration || ''} type='number' min={0} step={1} onChange={this.props.onEditMonitorDuration} rightIcon={<span>days</span>} />
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

MonitoringSettingsComponent.propTypes = {
  timezone: PropTypes.string,
  monitorDuration: PropTypes.number,
  onEditTimezone: PropTypes.func,
  onEditMonitorDuration: PropTypes.func,
  children: PropTypes.element
}

const mapStateToProps = (state) => {
  return {
    timezone: state.campaign.data.timezone,
    monitorDuration: state.campaign.data.monitorDuration
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
