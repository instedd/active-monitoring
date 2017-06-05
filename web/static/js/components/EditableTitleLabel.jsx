import React, { Component } from 'react'
import PropTypes from 'prop-types'
import UntitledIfEmpty from './UntitledIfEmpty.jsx'
import TextField from 'react-md/lib/TextFields'

export default class EditableTitleLabel extends Component {
  constructor(props) {
    super(props)
    this.state = {
      editing: false
    }
    this.inputRef = null
  }

  handleClick() {
    if (!this.state.editing && !this.props.readOnly) {
      let editing = !this.state.editing
      this.setState({editing: editing})
    }
  }

  endEdit() {
    this.setState({editing: false})
  }

  endAndSubmit() {
    const { onSubmit } = this.props
    this.endEdit()
    onSubmit(this.inputRef.getField().value)
  }

  onKeyDown(event) {
    if (event.key == 'Enter') {
      this.endAndSubmit()
    } else if (event.key == 'Escape') {
      this.endEdit()
    }
  }

  setInput(node) {
    this.inputRef = node

    if (node) {
      // focus element when first rendered. react-md's TextField doesn't support autofocus.
      node.focus()
    }
  }

  render() {
    const { title, emptyText } = this.props

    let icon = null
    if (!title || title.trim() == '') {
      icon = <i className='material-icons'>mode_edit</i>
    }

    if (!this.state.editing) {
      return (
        <a className='app-header-title-view' onClick={e => this.handleClick(e)}>
          <span><UntitledIfEmpty text={title} emptyText={emptyText} /></span>
          {icon}
        </a>
      )
    } else {
      return (
        <TextField
          maxLength={255}
          defaultValue={title || ''}
          ref={node => this.setInput(node)}
          onKeyDown={e => this.onKeyDown(e)}
          onBlur={e => this.endAndSubmit(e)}
          className='app-header-title-edit md-cell md-cell--bottom' />
      )
    }
  }
}

EditableTitleLabel.propTypes = {
  onSubmit: PropTypes.func.isRequired,
  title: PropTypes.string,
  emptyText: PropTypes.string,
  editing: PropTypes.bool,
  readOnly: PropTypes.bool
}
