// @flow
import React, { Component } from 'react'
import SubNav from './SubNav'

export default class ActiveCampaignSubNav extends Component {
  props: {
    addButtonHandler: Function,
    campaignId: number,
    title: string
  }

  render() {
    let tabsList: { label: string, url: string }[] = [
      { label: 'Overview', url: `/campaigns/${this.props.campaignId}` },
      { label: 'Subjects', url: `/campaigns/${this.props.campaignId}/subjects` }
    ]

    return (
      <SubNav tabsList={tabsList} addButtonHandler={this.props.addButtonHandler}>
        {this.props.title}
      </SubNav>
    )
  }
}
