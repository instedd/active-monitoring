import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import SelectField from 'react-md/lib/SelectFields'
import { fetchChannels } from '../../actions/channels'
import { campaignUpdate } from '../../actions/campaign'

class SelectChannelStepComponent extends Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  componentWillMount() {
    this.props.fetchChannels()
  }

  render() {
    const handleChange = (value) => {
      const channel = this.props.channels.find((c) => c.id == value)
      if (channel.activeCampaign) {
        this.setState({error: `Channel is in use by campaign ${channel.activeCampaign.name}`})
      } else {
        this.setState({error: null})
        this.props.onChannelSelect(value)
      }
    }

    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>Select channel</h3>
            <p className='flow-text'>
              Choose a Verboice channel for running this campaign
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <SelectField
            id='channel'
            label='Channel'
            menuItems={this.props.channels}
            onChange={handleChange}
            itemValue='id'
            itemLabel='name'
            className='md-cell md-cell--6'
            value={this.props.channelId}
           />
        </div>
        <div className='md-grid'>
          <p className='error-message md-cell md-cell--12'>{this.state.error}</p>
        </div>
      </div>
    )
  }
}

SelectChannelStepComponent.propTypes = {
  channelId: PropTypes.number,
  channels: PropTypes.arrayOf(PropTypes.object),
  fetchChannels: PropTypes.func.isRequired,
  onChannelSelect: PropTypes.func.isRequired
}

const mapStateToProps = (state) => {
  return {
    channelId: state.campaign.data && state.campaign.data.channelId,
    channels: state.channels.items || []
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    fetchChannels: () => dispatch(fetchChannels()),
    onChannelSelect: (id) => dispatch(campaignUpdate({channelId: id}))
  }
}

const SelectChannelStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(SelectChannelStepComponent)

export default SelectChannelStep
