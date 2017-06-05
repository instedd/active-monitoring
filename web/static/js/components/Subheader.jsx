import React, {Component} from 'react'
import PropTypes from 'prop-types'
import AddButton from './AddButton.jsx'

export default class Subheader extends Component {
  render() {
    var addButton = null
    if (this.props.addButtonHandler) {
      addButton = <AddButton onClick={this.props.addButtonHandler} />
    }

    return (
      <section className='md-grid app-subheader'>
        <h3 className='md-cell--4 md-cell--middle' style={{position: 'relative'}}>
          <div style={{position: 'absolute', left: '-80px', top: '-15px'}}>
            <object type='image/svg+xml' data='/images/icon.svg' width='60' height='60' />
          </div>
          {this.props.children}
        </h3>
        { addButton }
      </section>
    )
  }
}

Subheader.propTypes = {
  addButtonHandler: PropTypes.func,
  children: PropTypes.node.isRequired
}
