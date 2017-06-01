import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'
import * as actions from '../actions/campaigns'
import React, {Component} from 'react'
import { NavLink } from 'react-router-dom'
import DataTable from 'react-md/lib/DataTables/DataTable'
import TableHeader from 'react-md/lib/DataTables/TableHeader'
import TableBody from 'react-md/lib/DataTables/TableBody'
import TableRow from 'react-md/lib/DataTables/TableRow'
import TableColumn from 'react-md/lib/DataTables/TableColumn'

import EmptyListing from "./EmptyListing.jsx"
import Subheader from "./Subheader.jsx"

class CampaignsList extends Component {
  render() {
    const campaigns = this.props.items || []

    if (campaigns.length == 0) {
      return (
        <EmptyListing image="/images/campaign.svg">
          You have no campaigns yet
          <NavLink to="#">Create one</NavLink>
        </EmptyListing>
      )
    }

    return (
      <DataTable plain className="app-listing">
        <TableHeader>
          <TableRow>
            <TableColumn>Name</TableColumn>
            <TableColumn>Role</TableColumn>
            <TableColumn>Last Activity</TableColumn>
          </TableRow>
        </TableHeader>
        <TableBody>
          { campaigns.map(c => <CampaignItem key={c.id} campaign={c}></CampaignItem>) }
        </TableBody>
      </DataTable>
    )
  }
}

class CampaignItem extends Component {
  render() {
    const campaign = this.props.campaign
    return (
      <TableRow>
        <TableColumn>{campaign.name}</TableColumn>
        <TableColumn>...</TableColumn>
        <TableColumn>...</TableColumn>
      </TableRow>
    )
  }
}

class Campaigns extends Component {
  componentWillMount() {
    this.props.actions.fetchCampaigns()
  }

  render() {
    return (
      <div>
        <Subheader title="Campaigns"/>
        <CampaignsList items={this.props.campaigns.items}/>
      </div>
    )
  }
}

const mapStateToProps = (state) => ({
  campaigns: state.campaigns
})

const mapDispatchToProps = (dispatch) => ({
  actions: bindActionCreators(actions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Campaigns)
