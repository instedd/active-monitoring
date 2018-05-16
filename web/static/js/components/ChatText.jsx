// @flow
import React, { Component } from 'react'
import { connect } from 'react-redux'
import TextField from 'react-md/lib/TextFields'
import { editCampaignChatText } from '../actions/chat_texts'

type Props = {
  title: string,
  description: string,
  text: ?string,
  step: string,
  language: string,
  onEditCampaignChatText: (text: string, step: string, language: ?string) => void,
}

export class ChatTextComponent extends Component<Props> {
  onBlurChatText(event: any) {
    this.props.onEditCampaignChatText(event.target.value, this.props.step, this.props.language)
  }

  render() {
    return (
      <div className='md-cell md-cell--12 audio-picker rounded-corners'>
        <div className='md-grid'>
          <div className='mdockd-cell md-cell--12'>
            <h3>{this.props.title}</h3>
            <p>{this.props.description}</p>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <TextField
              rows={2}
              defaultValue={this.props.text || ''}
              onBlur={(e) => this.onBlurChatText(e)}
            />
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state, ownProps) => {
  return {
    step: ownProps.step,
    language: ownProps.language
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onEditCampaignChatText: (text, step, language) => dispatch(editCampaignChatText(text, step, language))
  }
}

const ChatText = connect(
  mapStateToProps,
  mapDispatchToProps
)(ChatTextComponent)

export default ChatText
