import PropTypes from 'prop-types'
import React, {Component} from 'react'
import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'

import * as actions from '../../actions/campaign'
import CampaignTitle from './CampaignTitle'
import SubNav from '../SubNav'
import CampaignCreationForm from './CampaignCreationForm'
import CampaignDashboard from './CampaignDashboard'
import ActiveCampaignSubNav from '../ActiveCampaignSubNav'

class Campaign extends Component {
  componentWillMount() {
    const { campaignId, data } = this.props.campaign

    if (this.props.id != campaignId || !data) {
      this.props.actions.campaignFetch(this.props.id)
    }
  }

  render() {
    if (this.props.campaign.fetching || !this.props.campaign.data) {
      return <div />
    } else {
      let content = null
      let subNav = null
      if (this.props.campaign.data.startedAt != undefined) {
        subNav = <ActiveCampaignSubNav title={this.props.campaign.data.name} campaignId={this.props.campaign.campaignId} />
        content = <CampaignDashboard campaign={this.props.campaign.data}
          call_stats={this.props.campaign.data.calls}
          subject_stats={this.props.campaign.data.subjects} />
      } else {
        subNav = <SubNav><CampaignTitle campaign={this.props.campaign.data} /></SubNav>
        content = <CampaignCreationForm campaign={this.props.campaign.data} />
      }

      return (
        <div className='md-grid--no-spacing'>
          {subNav}
          {content}
        </div>
      )
    }
  }
}

Campaign.propTypes = {
  actions: PropTypes.object.isRequired,
  id: PropTypes.number.isRequired,
  campaign: PropTypes.object.isRequired
}

const mapStateToProps = (state, ownProps) => {
  return {
    id: parseInt(ownProps.match.params.id),
    campaign: state.campaign
  }
}

const mapDispatchToProps = (dispatch) => ({
  actions: bindActionCreators(actions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Campaign)
