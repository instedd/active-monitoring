import React, { Component } from 'react'
import Dropzone from 'react-dropzone'
import PropTypes from 'prop-types'

class AudioDropzone extends Component {
  render() {
    const { onDrop, onDropRejected, error } = this.props

    let className = 'dropfile audio'
    if (error) className = `${className} error`

    return (
      <Dropzone className={className}
                activeClassName='active'
                rejectClassName='rejectedfile'
                multiple={false}
                onDrop={onDrop}
                onDropRejected={onDropRejected}
                accept='audio/*' >
        {this.props.children}
      </Dropzone>
    )
  }
}

AudioDropzone.propTypes = {
  onDrop: PropTypes.func,
  onDropRejected: PropTypes.func,
  error: PropTypes.bool
}

export default AudioDropzone
