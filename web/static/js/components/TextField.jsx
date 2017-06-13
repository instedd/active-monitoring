import React, { Component } from 'react'
import PropTypes from 'prop-types'
import MdTextField from 'react-md/lib/TextFields'

export default class TextField extends Component {
  constructor(props) {
    super(props)
    this.inputRef = null
  }

  endAndSubmit() {
    const { onSubmit } = this.props
    onSubmit(this.inputRef.getField().value)
  }

  onKeyDown(event) {
    if (event.key == 'Enter') {
      this.inputRef.getField().blur()
    }
  }

  setInput(node) {
    this.inputRef = node
  }

  render() {
    return (
      <MdTextField
        {...this.props}
        ref={node => this.setInput(node)}
        onKeyDown={e => this.onKeyDown(e)}
        onBlur={e => this.endAndSubmit()}
      />
    )
  }
}

TextField.defaultProps = MdTextField.defaultProps

TextField.propTypes = {
  ...MdTextField.propTypes,
  onSubmit: PropTypes.func.isRequired
}
