import React, {Component} from 'react'
import PropTypes from 'prop-types'
import AddButton from './AddButton'

const IconActive = () =>
  <img src='http://localhost:4001/images/icon.svg' width='60' height='60'/>

export default class SubNav extends Component {
  render() {
    let addButton = null
    if (this.props.addButtonHandler) {
      addButton = <AddButton onClick={this.props.addButtonHandler} />
    }

    return (
      <nav className='sub-nav'>
        <IconActive />
        <h1>{this.props.children}</h1>
        { addButton }
      </nav>
    )
  }
}

SubNav.propTypes = {
  addButtonHandler: PropTypes.func,
  children: PropTypes.node
}

