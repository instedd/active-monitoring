// @flow
import { connect } from 'react-redux'
import React, { Component } from 'react'
import { campaignUpdate } from '../../actions/campaign'
import TextField from 'react-md/lib/TextFields'
import Button from 'react-md/lib/Buttons/Button'
import type { Campaign } from '../../types'

type Props = {
  campaign: Campaign,
  fbPageId: string,
  fbVerifyToken: string,
  fbAccessToken: string,
  onEditFbPageId: (string) => void,
  onEditFbVerifyToken: (string) => void,
  onEditFbAccessToken: (string) => void
}

class BotChannelSelectionComponent extends Component<Props> {
  openFbPageInfo() {
    window.open('https://www.facebook.com/business/products/pages')
  }

  openFbBotInfo() {
    window.open('https://developers.facebook.com/docs/messenger-platform/getting-started/app-setup')
  }

  render() {
    const { campaign } = this.props

    return (
      <section id='channel' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Setup a Facebook channel</h1>
            <p>
              Before the campaign can start you need to create Facebook page and then subscribe a bot.
            </p>

            <Button flat primary label='Read about How to create a Facebook Page' onClick={this.openFbPageInfo}>info</Button>
            <Button flat primary label='Read about How to subscribe a Facebook Bot' onClick={this.openFbBotInfo}>info</Button>
          </div>
        </div>
        <div className='md-grid'>
          <TextField
            label='Facebook Page Id'
            id='fb-page-id'
            defaultValue={campaign.fbPageId || ''}
            onBlur={(e) => this.props.onEditFbPageId(e.target.value)}
          />
          <TextField
            label='Verify Token'
            id='fb-verify-token'
            defaultValue={campaign.fbVerifyToken || ''}
            onBlur={(e) => this.props.onEditFbVerifyToken(e.target.value)}
          />
          <TextField
            label='Access Token'
            id='fb-access-token'
            defaultValue={campaign.fbAccessToken || ''}
            onBlur={(e) => this.props.onEditFbAccessToken(e.target.value)}
          />
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <p>
              Don't forget to set the Callback URL on your Facebook Page
            </p>
            <TextField label='Facebook Callback URL' id='facebook-callback-url' value={`${location.protocol}//${location.host}/callback/facebook`} readOnly />
          </div>
        </div>
      </section>
    )
  }
}

const mapStateToProps = (state, ownProps) => {
  return {
    campaign: ownProps.campaign,
    fbPageId: state.campaign.data.fbPageId,
    fbVerifyToken: state.campaign.data.fbVerifyToken,
    fbAccessToken: state.campaign.data.fbAccessToken
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onEditFbPageId: (fbPageId) => dispatch(campaignUpdate({ fbPageId })),
    onEditFbVerifyToken: (fbVerifyToken) => dispatch(campaignUpdate({ fbVerifyToken })),
    onEditFbAccessToken: (fbAccessToken) => dispatch(campaignUpdate({ fbAccessToken }))
  }
}

const BotChannelStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(BotChannelSelectionComponent)

export default BotChannelStep
