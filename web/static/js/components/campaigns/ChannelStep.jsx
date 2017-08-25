import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { campaignUpdate } from '../../actions/campaign'
import * as authActions from '../../actions/authorizations'
import * as channelActions from '../../actions/channels'
import SelectField from 'react-md/lib/SelectFields'
import Paper from 'react-md/lib/Papers'
import Dialog from 'react-md/lib/Dialogs'
import List from 'react-md/lib/Lists'
import ListItemControl from 'react-md/lib/Lists/ListItemControl'
import Switch from 'react-md/lib/SelectionControls/Switch'
import FontIcon from 'react-md/lib/FontIcons'
import Button from 'react-md/lib/Buttons/Button'
import SelectionControlGroup from 'react-md/lib/SelectionControls/SelectionControlGroup'
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
      return <Switch id="switch" label='' name='providerSwitch' checked={checked} onChange={() => this.toggleProvider(provider, index, false)} disabled={disabled} />
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
    if(this.props.channels.items) {
      channelControl =
        (<SelectionControlGroup
          id='channel-select'
          name='channel-select'
          controls={this.props.channels.items.map(function(name){return {label: name, value: name} })}
          className='md-cell md-cell--12'
          type='radio'
          value={this.props.selectedChannel}
          onChange={(val) => this.props.onChangeChannel(val)}
        />)
    }
    return (
      <section id='channel'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Choose a channel</h1>
            <p>
              Before the campaign can start you need to select a Verboice channel to receive the incoming calls.
            </p>
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
  channelId: PropTypes.string,
  children: PropTypes.array,
  channels: PropTypes.object
}

const mapStateToProps = (state) => {
  return {
    channels: state.channels,
    authorizations: state.authorizations,
    selectedChannel: state.campaign.data.channel
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onChangeChannel: (value) => dispatch(campaignUpdate({channel: value})),
    toggleProvider: (provider, index) => dispatch(authActions.toggleAuthorization(provider, index)),
    fetchAuthorizations: () => dispatch(authActions.fetchAuthorizations()),
    fetchChannels: () => dispatch(channelActions.fetchChannels())
  }
}

const ChannelStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(ChannelSelectionComponent)

export default ChannelStep
