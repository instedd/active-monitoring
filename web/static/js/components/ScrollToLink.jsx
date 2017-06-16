// @flow
import React, { Component } from 'react'
import PropTypes from 'prop-types'

export class ScrollToLink extends Component {
  render() {
    const { children, target } = this.props

    return (
      <a href='#' className='scrollToLink' onClick={(e) => animatedScrollTo(e, target)}>
        <i className='material-icons'>keyboard_arrow_down</i>
        <span>{children}</span>
      </a>
    )
  }
}

ScrollToLink.propTypes = {
  target: PropTypes.string.isRequired,
  children: PropTypes.node
}

export const animatedScrollTo = (e: Event, target: string) => {
  e.preventDefault()

  // $('html, body').animate({
  //   scrollTop: $(target).offset().top
  // }, 500)
  var el = document.getElementById(target)
  var rect = el.getBoundingClientRect()
  window.scrollTo(0, rect.top)
}
