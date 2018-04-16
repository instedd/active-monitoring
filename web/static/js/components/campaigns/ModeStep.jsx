// @flow
import { connect } from 'react-redux'
import React, { Component } from 'react'
import { campaignUpdate } from '../../actions/campaign'
import Radio from 'react-md/lib/SelectionControls/Radio'

type Props = {
  mode: string,
  onEdit: (mode: string) => void,
}

class ModeStepComponent extends Component<Props> {
  render() {
    return (
      <section id='mode' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Choose how you communicate with subjects</h1>
            <p>
              You can either communicate with them through phone calls or a
              Facebook Chatbot.
            </p>
          </div>
          <div className='md-cell md-cell--12'>
            <Radio
              id='call'
              name='call'
              value='call'
              label='ActiveMonitoring will call subjects'
              checked={this.props.mode == 'call'}
              onChange={() => this.props.onEdit('call')}
              className='margin-left-none'
            />
            <Radio
              id='chat'
              name='chat'
              value='chat'
              label='ActiveMonitoring will chat with subjects'
              checked={this.props.mode == 'chat'}
              onChange={() => this.props.onEdit('chat')}
              className='margin-left-none'
            />
          </div>
        </div>
      </section>
    )
  }
}

const mapStateToProps = (state, ownProps) => {
  const campaign = ownProps.campaign
  return {
    mode: campaign.mode
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onEdit: (mode) => dispatch(campaignUpdate({ mode: mode }))
  }
}

const ModeStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(ModeStepComponent)

export default ModeStep
