// @flow
import React, { Component } from 'react'
import PropTypes from 'prop-types'

export class ScrollToLink extends Component {
  static get propTypes() {
    return {
      target: PropTypes.string.isRequired,
      children: PropTypes.node
    }
  }

  render() {
    const { children, target } = this.props

    return <a href='#' className='scrollToLink' onClick={(e) => animatedScrollTo(e, target)}>
      <i className='material-icons'>keyboard_arrow_down</i>
      <span>{children}</span>
    </a>
  }
}

export const animatedScrollTo = (e: Event, target: String) => {
  e.preventDefault()

  // $('html, body').animate({
  //   scrollTop: $(target).offset().top
  // }, 500)
  var el = document.getElementById(target)
  var rect = el.getBoundingClientRect()
  window.scrollTo(0, rect.top)
}
