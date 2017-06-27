import React, {Component} from 'react'
import PropTypes from 'prop-types'
import AddButton from './AddButton'

const IconActive = () =>
  <object type='image/svg+xml' data='/images/icon.svg' width='60' height='60'/>

export default class Subheader extends Component {
  render() {
    let addButton = null
    if (this.props.addButtonHandler) {
      addButton = <AddButton onClick={this.props.addButtonHandler} />
    }

    return (
      <div className='sub-nav'>
        <IconActive />
        <h1>{this.props.children}</h1>
        { addButton }
      </div>
    )
  }
}

Subheader.propTypes = {
  addButtonHandler: PropTypes.func,
  children: PropTypes.node.isRequired
}

