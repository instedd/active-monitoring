import React, {Component} from 'react'
import Button from 'react-md/lib/Buttons/Button'

export default class Subheader extends Component {
  render() {
    return (
      <section className="md-grid app-subheader">
        <h3 className="md-cell--4 md-cell--middle" style={{position: "relative"}}>
          <div style={{position: "absolute", left: "-80px", top: "-15px"}}>
            <object type="image/svg+xml" data="/images/icon.svg" width="60" height="60"></object>
          </div>
          {this.props.title}
        </h3>
        <Button
          floating
          primary
          style={{position: "relative", bottom: "-38px"}}
          className="md-cell--right md-cell--bottom">
          add
        </Button>
      </section>
    )
  }
}
