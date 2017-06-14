import React, { Component } from 'react'
import AudioDropzone from './AudioDropzone'
import PropTypes from 'prop-types'
import FontIcon from 'react-md/lib/FontIcons'
import Paper from 'react-md/lib/Papers'
import { createAudio } from '../api.js'

export class AudioPicker extends Component {
  onUpload(files) {
    console.log(files)
    createAudio(files)
  }

  render() {
    return (
      <Paper zDepth={1} className='md-cell md-cell--12'>
        <AudioDropzone onDrop={this.onUpload}>
          <div className='md-grid'>
            <div className='md-cell md-cell--10'>
              <h3>{this.props.title}</h3>
              <p>{this.props.description}</p>
            </div>
            <FontIcon className='md-cell md-cell--2 md-cell--right md-text-right'>file_upload</FontIcon>
          </div>
        </AudioDropzone>
      </Paper>
    )
  }
}

AudioPicker.propTypes = {
  title: PropTypes.string,
  description: PropTypes.string
}

export default AudioPicker
