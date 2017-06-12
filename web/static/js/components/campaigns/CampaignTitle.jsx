import * as actions from '../../actions/campaign'
import EditableTitleLabel from '../EditableTitleLabel'
import PropTypes from 'prop-types'
import React, { Component } from 'react'
import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'

class CampaignTitle extends Component {
  handleSubmit(newName) {
    const { campaign } = this.props
    if (campaign.name == newName) return

    // trigger request to update in the server
    this.props.actions.campaignUpdate({ name: newName })
  }

  render() {
    return (
      <EditableTitleLabel
        title={this.props.campaign.name}
        emptyText={'Untitled campaign'}
        readOnly={false}
        onSubmit={(title) => this.handleSubmit(title)}
        maxLength={255} />
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
