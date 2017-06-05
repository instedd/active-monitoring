import * as actions from '../../actions/campaign.js'
import EditableTitleLabel from '../EditableTitleLabel.jsx'
import PropTypes from 'prop-types'
import React, { Component } from 'react'
import merge from 'lodash/merge'
import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'

class CampaignTitle extends Component {
  handleSubmit(newName) {
    const { campaign } = this.props
    if (campaign.name == newName) return

    const newCampaign = merge({}, campaign, {name: newName})

    // optimistic update of client-side data.
    this.props.actions.campaignUpdated(newCampaign)

    // trigger request to update in the server.
    this.props.actions.campaignUpdate(newCampaign)
  }

  render() {
    return (
      <EditableTitleLabel
        title={this.props.campaign.name}
        emptyText={'Untitled campaign'}
        readOnly={false}
        onSubmit={(title) => this.handleSubmit(title)} />
    )
  }
}

CampaignTitle.propTypes = {
  campaign: PropTypes.object,
  actions: PropTypes.object.isRequired
}

const mapStateToProps = (state) => ({})

const mapDispatchToProps = (dispatch) => ({
  actions: bindActionCreators(actions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(CampaignTitle)
