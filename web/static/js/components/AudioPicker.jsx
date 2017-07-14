import React, { Component } from 'react'
import AudioDropzone from './AudioDropzone'
import PropTypes from 'prop-types'
import FontIcon from 'react-md/lib/FontIcons'
import Paper from 'react-md/lib/Papers'

export class AudioPicker extends Component {
  constructor(props) {
    super(props)
    this.state = {}
  }

  componentWillReceiveProps(newProps) {
    if (newProps.file != this.file) {
      this.setState({uploading: false})
    }
  }

  render() {
    const handleUpload = (file) => {
      this.setState({uploading: true})
      this.props.onUpload(file)
    }

    const uploadingControl = this.state.uploading && (
      <span>Uploading...</span>
    )

    const audioPlayer = this.props.file && (
      <audio controls>
        <source src={`/api/v1/audios/${this.props.file}`} type='audio/mpeg' />
      </audio>
    )

    const action = this.props.file ? (
      <FontIcon onClick={(e) => { e.stopPropagation(); this.props.onRemove() }} className='pull-right cursor'>close</FontIcon>
    ) : (
      <FontIcon className='pull-right cursor'>file_upload</FontIcon>
    )

    return (
      <Paper zDepth={1} className='md-cell md-cell--12 audio-picker'>
        <AudioDropzone onDrop={handleUpload}>
          <div className='md-grid'>
            <div className='md-cell md-cell--12'>
              {action}
              <h3>{this.props.title}</h3>
              <p>{this.props.description}</p>
            </div>
          </div>
          <div className='md-grid'>
            <div className='md-cell md-cell--12'>
              {uploadingControl || audioPlayer}
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
