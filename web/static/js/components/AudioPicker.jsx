import React, { Component } from 'react'
import AudioDropzone from './AudioDropzone'
import PropTypes from 'prop-types'
import FontIcon from 'react-md/lib/FontIcons'
import Paper from 'react-md/lib/Papers'

export class AudioPicker extends Component {
  render() {
    const audioPlayer = this.props.file && (
      <audio controls>
        <source src={`/api/v1/audios/${this.props.file}`} type='audio/mpeg' />
      </audio>
    )

    const action = this.props.file ? (
      <FontIcon onClick={(e) => { e.stopPropagation(); this.props.onRemove(); }} className='md-cell md-cell--2 md-cell--right md-text-right'>close</FontIcon>
    ) : (
      <FontIcon className='md-cell md-cell--2 md-cell--right md-text-right'>file_upload</FontIcon>
    )

    return (
      <Paper zDepth={1} className='md-cell md-cell--12 audio-picker'>
        <AudioDropzone onDrop={this.props.onUpload}>
          <div>
            <div className='md-grid'>
              <div className='md-cell md-cell--10'>
                <h3>{this.props.title}</h3>
                <p>{this.props.description}</p>
              </div>
              {action}
            </div>
            <div className='md-grid'>
              <div className='md-cell md-cell--10'>
                {audioPlayer}
              </div>
            </div>
          </div>
        </AudioDropzone>
      </Paper>
    )
  }
}

AudioPicker.propTypes = {
  title: PropTypes.string.isRequired,
  description: PropTypes.string,
  onUpload: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired,
  file: PropTypes.string
}

export default AudioPicker
