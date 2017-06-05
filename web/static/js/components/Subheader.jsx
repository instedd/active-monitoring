import React, {Component} from 'react'
import PropTypes from 'prop-types'

export default class Subheader extends Component {
  render() {
    return (
      <section className='md-grid app-subheader'>
        <h3 className='md-cell--4 md-cell--middle' style={{position: 'relative'}}>
          <div style={{position: 'absolute', left: '-80px', top: '-15px'}}>
            <object type='image/svg+xml' data='/images/icon.svg' width='60' height='60' />
          </div>
          {this.props.title}
        </h3>
        {this.props.children}
      </section>
    )
  }
}

Subheader.propTypes = {
  title: PropTypes.string.isRequired,
  children: PropTypes.node
}
