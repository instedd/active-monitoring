// @flow
import React, { Component } from 'react'
import Radio from 'react-md/lib/SelectionControls/Radio'

class ModeStepComponent extends Component<{}> {
  onEdit(newValue: string) {
  }

  render() {
    return (
      <section id='mode' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Choose how you communicate with monitorees</h1>
            <p>
              You can either communicate with them through phone calls or a Facebook chatbot.
            </p>
          </div>
          <div className='md-cell md-cell--12'>
            <Radio
              id='call'
              name='call'
              value='call'
              label='ActiveMonitoring will call subjects'
              // checked={this.props.additionalInformation === 'zero'}
              onChange={() => this.onEdit('call')}
              className='margin-left-none'
            />
            <Radio
              id='chat'
              name='chat'
              value='chat'
              label='ActiveMonitoring will chat with subjects'
              // checked={this.props.additionalInformation === 'zero'}
              onChange={() => this.onEdit('chat')}
              className='margin-left-none'
            />
          </div>
        </div>
      </section>
    )
  }
}

const ModeStep = ModeStepComponent

export default ModeStep
