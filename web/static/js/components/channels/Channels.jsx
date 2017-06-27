import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { bindActionCreators } from 'redux'
import { connect } from 'react-redux'
import { NavLink } from 'react-router-dom'
import Card from 'react-md/lib/Cards/Card';
import DataTable from 'react-md/lib/DataTables/DataTable'
import TableHeader from 'react-md/lib/DataTables/TableHeader'
import TableBody from 'react-md/lib/DataTables/TableBody'
import TableRow from 'react-md/lib/DataTables/TableRow'
import TableColumn from 'react-md/lib/DataTables/TableColumn'

import * as collectionActions from '../../actions/channels'
import EmptyListing from '../EmptyListing'
import Subheader from '../Subheader'

class ChannelsList extends Component {
  render() {
    const channels = this.props.items || []

    if (channels.length == 0) {
      return (
        <EmptyListing image='/images/campaign.svg'>
          You have no channels yet
          <NavLink to='#' onClick={this.props.addChannels}>Add channels</NavLink>
        </EmptyListing>
      )
    }

    const rows = channels.map(c => <ChannelItem key={c.id} channel={c} />)

    return (
       <div className='md-grid'>
        <div className='md-cell--12'>
          <Card tableCard>
            <DataTable plain className='app-listing'>
              <TableHeader>
                <TableRow>
                  <TableColumn>Name</TableColumn>
                  <TableColumn>Provider</TableColumn>
                  <TableColumn>Active campaign</TableColumn>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows}
              </TableBody>
            </DataTable>
          </Card>
        </div>
      </div>
    )
  }
}

ChannelsList.propTypes = {
  addChannels: PropTypes.func.isRequired,
  items: PropTypes.array
}

class ChannelItem extends Component {
  render() {
    const { channel } = this.props
    return (
      <TableRow>
        <TableColumn>{channel.name}</TableColumn>
        <TableColumn>{channel.provider}</TableColumn>
        <TableColumn>{channel.active_campaign}</TableColumn>
      </TableRow>
    )
  }
}

ChannelItem.propTypes = {
  channel: PropTypes.shape({
    name: PropTypes.string,
    provider: PropTypes.string,
    active_campaign: PropTypes.string
  }).isRequired
}

class Channels extends Component {
  componentWillMount() {
    this.props.collectionActions.fetchChannels()
  }

  addChannels() {
    console.log('Add channels clicked')
  }

  render() {
    return (
      <div className='md-grid--no-spacing'>
        <Subheader addButtonHandler={() => this.addChannels()}>
          Channels
        </Subheader>
        <ChannelsList
          items={this.props.channels.items}
          addChannels={() => this.addChannels()} />
      </div>
    )
  }
}

Channels.propTypes = {
  collectionActions: PropTypes.object.isRequired,
  channels: PropTypes.object.isRequired
}

const mapStateToProps = (state) => ({
  channels: state.channels
})

const mapDispatchToProps = (dispatch) => ({
  collectionActions: bindActionCreators(collectionActions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Channels)
