// @flow
import React, { Component } from 'react'
import type {Node} from 'react'
import PropTypes from 'prop-types'
import Button from 'react-md/lib/Buttons/Button'
import $ from 'jquery'

type Props = {
  target: string,
  children: Node
}

export class ScrollToLink extends Component<Props> {
  render() {
    const { children, target } = this.props

    return (
      <Button flat primary className='scrollToLink' onClick={(e) => animatedScrollTo(e, target)} label={children}>
        keyboard_arrow_down
      </Button>
    )
  }
}

ScrollToLink.propTypes = {
  target: PropTypes.string.isRequired,
  children: PropTypes.node
}

export const animatedScrollTo = (e: Event, target: string) => {
  e.preventDefault()
  $('html, body').animate({
    scrollTop: $(`#${target}`).offset().top
  }, 500)
}
