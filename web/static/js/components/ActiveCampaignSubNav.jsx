// @flow
import React, { Component } from 'react'
import SubNav from './SubNav'

type Props = {
  addButtonHandler: Function,
  campaignId: number,
  title: string
};

export default class ActiveCampaignSubNav extends Component<Props> {
  render() {
    const { addButtonHandler, title, campaignId } = this.props

    let tabsList: { label: string, url: string }[] = [
      { label: 'Overview', url: `/campaigns/${campaignId}` },
      { label: 'Subjects', url: `/campaigns/${campaignId}/subjects` }
    ]

    return (
      <SubNav tabsList={tabsList} addButtonHandler={addButtonHandler}>
        {title}
      </SubNav>
    )
  }
}
