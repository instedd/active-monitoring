import React, { Component } from 'react'
import PropTypes from 'prop-types'

export default class UntitledIfEmpty extends Component {
  render() {
    const { text, emptyText = 'Untitled', className } = this.props

    if (!text || text.trim() == '') {
      return <em className={className}>{emptyText}</em>
    } else {
      return <span className={className}>{text}</span>
    }
  }
}

UntitledIfEmpty.propTypes = {
  text: PropTypes.string,
  emptyText: PropTypes.string,
  className: PropTypes.string
}
