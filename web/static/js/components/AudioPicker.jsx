import React, { Component } from 'react'
import AudioDropzone from './AudioDropzone'
import PropTypes from 'prop-types'
import FontIcon from 'react-md/lib/FontIcons'
import Paper from 'react-md/lib/Papers'

export class AudioPicker extends Component {
  render() {
    return (
      <Paper zDepth={1} className="md-cell md-cell--12">
        <AudioDropzone>
          <div className="md-grid">
            <div className="md-cell md-cell--10">
              <h3>{this.props.title}</h3>
              <p>{this.props.description}</p>
            </div>
            <FontIcon className="md-cell md-cell--2 md-cell--right md-text-right">file_upload</FontIcon>
          </div>
        </AudioDropzone>
      </Paper>
    )
  }
}

AudioPicker.propTypes = {
  topic: PropTypes.string,
  title: PropTypes.string,
  description: PropTypes.string
}

export default AudioPicker
