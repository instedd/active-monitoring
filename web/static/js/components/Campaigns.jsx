import React, { Component } from 'react'
import Button from 'react-md/lib/Buttons/Button'

class CampaignsHeader extends Component {
  render() {
    return (
      <section className="md-grid app-subheader">
        <h3 className="md-cell--4 md-cell--middle">
          Campaigns
        </h3>
        <Button
          floating
          primary
          className="md-cell--right md-cell--bottom">
          add
        </Button>
      </section>
    )
  }
}

export default class Campaigns extends Component {
  render() {
    return (
      <CampaignsHeader />
    )
  }
}
