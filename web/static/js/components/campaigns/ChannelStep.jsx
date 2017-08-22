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
import ListItem from 'react-md/lib/Lists'
import Switch from 'react-md/lib/SelectionControls/Switch'
import Button from 'react-md/lib/Buttons/Button'
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
  }

  componentDidMount() {
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
      return <div className='switch'>
        <Switch id="switch" label='' name='providerSwitch' checked={checked} onChange={() => this.toggleProvider(provider, index, false)} disabled={disabled} />
      </div>
    }

    // const providerModal = (provider, index, friendlyName, multiple) => {
    //   let name = `${provider[0].toUpperCase()}${provider.slice(1)}`
    //   if (multiple) name = `${name} (${friendlyName})`

    //   return <ConfirmationModal key={`${provider}-${index}`} modalId={`${provider}Modal-${index}`} modalText={`Do you want to delete the channels provided by ${name}?`} header={`Turn off ${name}`} confirmationText='Yes' onConfirm={() => this.deleteProvider(provider, index)} style={{maxWidth: '600px'}} showCancel />
    // }

    const multipleVerboice = config['verboice'].length > 1

    let providerModals = []
    // for (let index in verboices) {
    // providerModals.push(providerModal('verboice', 0, 'Verboice stg', multipleVerboice))
    // }

    const verboiceProviderUI = (index, multiple) => {
      let name = 'Verboice'
      if (multiple) name = `${name} (${config['verboice'][index].friendlyName})`

      return (
        <ListItem key={`verboice-${index}`} className={`verboice`}>
          <h5>{name}</h5>
          {providerSwitch('verboice', index)}
          <span className='channel-description'>
            <b>Voice channels</b>
            <br />
            Callcentric, SIP client, SIP server, Skype, Twillio
          </span>
          <span onClick={() => window.open(config['verboice'][index].baseUrl)}>
            <i className='material-icons arrow-right'>chevron_right</i>
          </span>
        </ListItem>
      )
    }

    let providerUIs = []
    for (let index in config['verboice']) {
      providerUIs.push(verboiceProviderUI(index, multipleVerboice))
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
          <SelectField
            id='channel-select'
            menuItems={this.props.channels.items || []}
            position={SelectField.Positions.BELOW}
            className='md-cell md-cell--8  md-cell--bottom'
            onChange={(val) => this.props.onChangeChannel(val)}
          />
          <div className='md-cell md-cell--4'>
            <Button raised label='Add channel provider' onClick={(e) => this.addProvider(e)} />
            {providerModals}

            <Dialog id='add-channel' visible={this.state.providerModalVisible} onHide={() => this.closeProviderModal()} title='Add channel provider' focusOnMount={false}>
              <div className='modal-content'>
                <div className='card-title header'>
                  <h5>Add channels from a new provider</h5>
                  <p>ActiveMonitoring will sync available channels from these providers after user authorization</p>
                </div>
                <List>
                  {providerUIs}
                </List>
              </div>
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
    authorizations: state.authorizations
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onChangeChannel: (value) => dispatch(campaignUpdate({channelId: value})),
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
