import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'
import * as actions from '../actions/campaigns'
import React, {Component} from 'react'
import DataTable from 'react-md/lib/DataTables/DataTable'
import TableHeader from 'react-md/lib/DataTables/TableHeader'
import TableBody from 'react-md/lib/DataTables/TableBody'
import TableRow from 'react-md/lib/DataTables/TableRow'
import TableColumn from 'react-md/lib/DataTables/TableColumn'
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

class CampaignsList extends Component {
  render() {
    const rows = []

    return (
      <DataTable plain>
        <TableHeader>
          <TableRow>
            <TableColumn>Name</TableColumn>
            <TableColumn>Role</TableColumn>
            <TableColumn>Last Activity</TableColumn>
          </TableRow>
        </TableHeader>
        <TableBody>
          {rows}
        </TableBody>
      </DataTable>
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
        <CampaignsHeader />
        <CampaignsList />
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
