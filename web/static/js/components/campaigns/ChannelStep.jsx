import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { campaignUpdate } from '../../actions/campaign'
import * as authActions from '../../actions/authorizations'
import * as channelActions from '../../actions/channels'
import * as campaignActions from '../../actions/campaigns'
import { activeCampaignUsing } from '../../reducers/campaigns'
import Paper from 'react-md/lib/Papers'
import Dialog from 'react-md/lib/Dialogs'
import List from 'react-md/lib/Lists'
import ListItemControl from 'react-md/lib/Lists/ListItemControl'
import Switch from 'react-md/lib/SelectionControls/Switch'
import FontIcon from 'react-md/lib/FontIcons'
import Button from 'react-md/lib/Buttons/Button'
import SelectionControlGroup from 'react-md/lib/SelectionControls/SelectionControlGroup'
import TextField from 'react-md/lib/TextFields'
import { config } from '../../config'

class ChannelSelectionComponent extends Component {
  constructor(props) {
    super(props)
    this.state = {
      providerModalVisible: false
    }
  }

  componentWillMount() {
    this.props.fetchAuthorizations()
    this.props.fetchChannels()
    this.props.fetchCampaigns()
  }

  openChannelSetupInfo() {
    window.open('https://github.com/instedd/active-monitoring/wiki/Setting-up-Verboice-channels')
  }

  openVerboiceSetup() {
    window.open(`${config['verboice'][0].baseUrl}/channels`)
  }

  addProvider(event) {
    event.preventDefault()
    this.setState({providerModalVisible: true})
  }

  closeProviderModal() {
    this.setState({providerModalVisible: false})
  }

  toggleProvider(provider, index, checked) {
    if (checked) {
      $(`#${provider}Modal-${index}`).modal('open')
    } else {
      this.props.toggleProvider(provider, index)
    }
  }

  turnOffProvider(provider, index) {
    authActions.removeAuthorization(provider, index)
  }

  deleteProvider(provider, index) {
    authActions.toggleAuthorization(provider, index)
  }

  channelOptions(channels) {
    const activeCampaignUsing = this.props.activeCampaignUsing

    return channels.map((name) => {
      const camp = activeCampaignUsing(name)
      return {
        label: name + (camp ? ` (in use by campaign ${camp.name})` : ''), value: name, disabled: camp !== undefined}
    })
  }

  render() {
    if (!this.props.channels) {
      return (
        <div>
          <Paper>Loading channels...</Paper>
        </div>
      )
    }

    const providerSwitch = (provider, index) => {
      const disabled = this.props.authorizations.fetching
      const checked = authActions.hasInAuthorizations(this.props.authorizations, provider, index)
      return <Switch id='switch' label='' name='providerSwitch' checked={checked} onChange={() => this.toggleProvider(provider, index, false)} disabled={disabled} />
    }

    const multipleVerboice = config['verboice'].length > 1

    let providerModals = []
    const verboiceProviderUI = (index, multiple) => {
      let name = 'Verboice'
      if (multiple) name = `${name} (${config['verboice'][index].friendlyName})`

      return (
        <ListItemControl
          key={`verboice-${index}`}
          className={`verboice`}
          rightIcon={<FontIcon onClick={() => window.open(config['verboice'][index].baseUrl)}>chevron_right</FontIcon>}
          primaryAction={providerSwitch('verboice', index)}
          primaryText={name}
          secondaryText='Callcentric, SIP client, SIP server, Skype, Twillio'
        />
      )
    }

    let providerUIs = []
    for (let index in config['verboice']) {
      providerUIs.push(verboiceProviderUI(index, multipleVerboice))
    }

    let channelControl = null
    if ((this.props.channels.items || []).length > 0) {
      channelControl =
        (<SelectionControlGroup
          id='channel-select'
          name='channel-select'
          controls={this.channelOptions(this.props.channels.items)}
          className='md-cell md-cell--12'
          type='radio'
          value={this.props.selectedChannel}
          onChange={(val) => this.props.onChangeChannel(val)}
        />)
    } else {
      if (this.props.channels.fetching || this.props.authorizations.fetching) {
        channelControl = 'Fetching available channels...'
      } else {
        if ((this.props.authorizations.items || []).length > 0) {
          channelControl = (<div className='md-cell md-cell--12'>
            <p>You don't have any channel available</p>
            <Button flat primary label='Setup a channel on Verboice' onClick={this.openVerboiceSetup}>open_in_new</Button>
          </div>)
        } else {
          channelControl = <p className='md-cell md-cell--12'>You don't have any provider configured - select Manage Providers below to start!</p>
        }
      }
    }

    return (
      <section id='channel'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Choose a channel</h1>
            <p>
              Before the campaign can start you need to select a Verboice channel to receive the incoming calls.
            </p>
            <TextField label='Call Flow callback URL' id='callflow-callback-url' value={`${location.protocol}//${location.host}/callbacks/verboice/${this.props.campaignId}`} readOnly />
            <TextField label='Project Status callback' id='project-status-callback' value={`${location.protocol}//${location.host}/callbacks/verboice/${this.props.campaignId}/status`} readOnly />
            <Button flat primary label='Read about channel setup' onClick={this.openChannelSetupInfo}>info</Button>
          </div>
        </div>
        <div className='md-grid'>
          {channelControl}
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--8'>
            <Button flat label='Manage providers' onClick={(e) => this.addProvider(e)}>settings</Button>
            {providerModals}
            <Dialog id='add-channel' visible={this.state.providerModalVisible} onHide={() => this.closeProviderModal()} title='Manage providers' focusOnMount={false}>
              <List>
                {providerUIs}
              </List>
            </Dialog>
          </div>
        </div>
      </section>
    )
  }
}

ChannelSelectionComponent.propTypes = {
  channels: PropTypes.object,
  campaignId: PropTypes.number,
  fetchAuthorizations: PropTypes.func,
  fetchChannels: PropTypes.func,
  fetchCampaigns: PropTypes.func,
  toggleProvider: PropTypes.func,
  activeCampaignUsing: PropTypes.func,
  authorizations: PropTypes.shape({
    fetching: PropTypes.bool,
    items: PropTypes.arrayOf(
      PropTypes.shape({
        provider: PropTypes.string,
        baseUrl: PropTypes.string
      })
    )
  }),
  selectedChannel: PropTypes.string,
  onChangeChannel: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    channels: state.channels,
    activeCampaignUsing: activeCampaignUsing(state.campaigns),
    authorizations: state.authorizations,
    selectedChannel: state.campaign.data.channel,
    campaignId: state.campaign.data.id
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onChangeChannel: (value) => dispatch(campaignUpdate({channel: value})),
    toggleProvider: (provider, index) => dispatch(authActions.toggleAuthorization(provider, index)),
    fetchAuthorizations: () => dispatch(authActions.fetchAuthorizations()),
    fetchChannels: () => dispatch(channelActions.fetchChannels()),
    fetchCampaigns: () => dispatch(campaignActions.fetchCampaigns())
  }
}

const ChannelStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(ChannelSelectionComponent)

export default ChannelStep
