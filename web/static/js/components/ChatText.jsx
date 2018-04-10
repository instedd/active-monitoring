// @flow
import React, { Component } from 'react'
import FontIcon from 'react-md/lib/FontIcons'

type Props = {
  title: string,
  description: string,
  text: ?string,
  onRemove: () => void,
  onAdd: (string) => void,
}

export class ChatText extends Component<Props> {
  render() {
    let action = this.props.text ? (
      <FontIcon onClick={(e) => { e.stopPropagation(); this.props.onRemove() }} className='pull-right cursor'>close</FontIcon>
    ) : null

    return (
      <div>
        <div className='md-grid'>
          <div className='mdockd-cell md-cell--12'>
            {action}
            <h3>{this.props.title}</h3>
            <p>{this.props.description}</p>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <textarea>{this.props.text}</textarea>
          </div>
        </div>
      </div>
    )
  }
}

export default ChatText
