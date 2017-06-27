import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Button from 'react-md/lib/Buttons/Button'

export default class AddButton extends Component {
  render() {
    return (
      <Button
        onClick={this.props.onClick}
        floating
        secondary
        className='md-cell--right md-cell--bottom add-button'>
      add
    </Button>
    )
  }
}

AddButton.propTypes = {
  onClick: PropTypes.func.isRequired
}
