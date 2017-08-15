import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { campaignUpdate } from '../../actions/campaign'
import * as authActions from '../../actions/authorizations'
import SelectField from 'react-md/lib/SelectFields'
import Paper from 'react-md/lib/Papers'
import Dialog from 'react-md/lib/Dialogs'
import List from 'react-md/lib/Lists'
import ListItem from 'react-md/lib/Lists'
import Switch from 'react-md/lib/SelectionControls/Switch'
import Button from 'react-md/lib/Buttons/Button'

class ChannelSelectionComponent extends Component {

  componentDidMount() {
    //this.props.actions.fetchChannels()
    authActions.fetchAuthorizations()
  }

  addChannel(event) {
    event.preventDefault()
    $('#add-channel').modal('open')
  }

  toggleProvider(provider, index, checked) {
    if (checked) {
      $(`#${provider}Modal-${index}`).modal('open')
    } else {
      authActions.toggleAuthorization(provider, index)
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
      // const disabled = authorizations.fetching
      // const checked = authActions.hasInAuthorizations(authorizations, provider, index)
      return <div className='switch'>
        <Switch id="switch" label='' name='providerSwitch' checked={false} onChange={() => this.toggleProvider(provider, index, false)} disabled={false} />
      </div>
    }

    // const providerModal = (provider, index, friendlyName, multiple) => {
    //   let name = `${provider[0].toUpperCase()}${provider.slice(1)}`
    //   if (multiple) name = `${name} (${friendlyName})`

    //   return <ConfirmationModal key={`${provider}-${index}`} modalId={`${provider}Modal-${index}`} modalText={`Do you want to delete the channels provided by ${name}?`} header={`Turn off ${name}`} confirmationText='Yes' onConfirm={() => this.deleteProvider(provider, index)} style={{maxWidth: '600px'}} showCancel />
    // }

    // let syncButton = null
    // if (authorizations.synchronizing) {
    //   syncButton = <Preloader size='small' />
    // } else {
    //   syncButton = <a href='#' className='black-text' onClick={() => this.synchronizeChannels()}>
    //     <i className='material-icons container-rotate'>refresh</i>
    //   </a>
    // }

    // const tableTitle =
    //   <span>
    //     { title }
    //     <span className='right'>{ syncButton }</span>
    //   </span>

    const verboices = [{friendlyName: "Verboice stg", baseUrl: "https://verboice-stg.instedd.org"}]
    const multipleVerboice = verboices.length > 1

    let providerModals = []
    // for (let index in verboices) {
    // providerModals.push(providerModal('verboice', 0, 'Verboice stg', multipleVerboice))
    // }

    const verboiceProviderUI = (index, multiple) => {
      let name = 'Verboice'
      if (multiple) name = `${name} (${verboices[index].friendlyName})`

      return (
        <ListItem key={`verboice-${index}`} className={`verboice`}>
          <h5>{name}</h5>
          {providerSwitch('verboice', index)}
          <span className='channel-description'>
            <b>Voice channels</b>
            <br />
            Callcentric, SIP client, SIP server, Skype, Twillio
          </span>
          <span onClick={() => window.open(verboices[index].baseUrl)}>
            <i className='material-icons arrow-right'>chevron_right</i>
          </span>
        </ListItem>
      )
    }

    let providerUIs = []
    for (let index in verboices) {
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
            menuItems={[]}
            position={SelectField.Positions.BELOW}
            className='md-cell md-cell--8  md-cell--bottom'
            value={this.props.channelId}
            onChange={(val) => this.props.onChange(val)}
          />
          <div className='md-cell md-cell--4'>
            <Button raised label='Add channel provider' onClick={(e) => this.addChannel(e)} />
            {providerModals}

            <Dialog id='add-channel' visible={true} onHide={() => console.log("hide")} title='Add channel provider'>
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
  channelId: PropTypes.number,
  children: PropTypes.array
}

const mapStateToProps = (state) => {
  console.log(state.channels)
  return {
    channels: state.channels
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onChange: (value) => dispatch(campaignUpdate({channelId: value}))
  }
}

const ChannelStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(ChannelSelectionComponent)

export default ChannelStep







// import { orderedItems } from '../reducers/collection'
// import * as authActions from '../actions/authorizations'
// import { AddButton, EmptyPage, CardTable, UntitledIfEmpty, SortableHeader, Modal, ConfirmationModal } from './ui'

// class ChannelIndex extends Component {
//   componentDidMount() {
//     this.props.actions.fetchChannels()
//   }


//   nextPage(e) {
//     e.preventDefault()
//     this.props.actions.nextChannelsPage()
//   }

//   previousPage(e) {
//     e.preventDefault()
//     this.props.actions.previousChannelsPage()
//   }

//   sortBy(property) {
//     this.props.actions.sortChannelsBy(property)
//   }

//   synchronizeChannels() {
//     this.props.authActions.synchronizeChannels()
//   }



// ChannelIndex.propTypes = {
//   actions: PropTypes.object.isRequired,
//   authActions: PropTypes.object.isRequired,
//   channels: PropTypes.array,
//   authorizations: PropTypes.object,
//   sortBy: PropTypes.string,
//   sortAsc: PropTypes.bool.isRequired,
//   pageSize: PropTypes.number.isRequired,
//   startIndex: PropTypes.number.isRequired,
//   endIndex: PropTypes.number.isRequired,
//   hasPreviousPage: PropTypes.bool.isRequired,
//   hasNextPage: PropTypes.bool.isRequired,
//   totalCount: PropTypes.number.isRequired
// }

// const mapStateToProps = (state) => {
//   let channels = orderedItems(state.channels.items, state.channels.order)
//   const sortBy = state.channels.sortBy
//   const sortAsc = state.channels.sortAsc

//   const totalCount = channels ? channels.length : 0
//   const pageIndex = state.channels.page.index
//   const pageSize = state.channels.page.size
//   if (channels) {
//     channels = channels.slice(pageIndex, pageIndex + pageSize)
//   }
//   const startIndex = Math.min(totalCount, pageIndex + 1)
//   const endIndex = Math.min(pageIndex + pageSize, totalCount)
//   const hasPreviousPage = startIndex > 1
//   const hasNextPage = endIndex < totalCount
//   return {
//     sortBy,
//     sortAsc,
//     channels,
//     pageSize,
//     startIndex,
//     endIndex,
//     hasPreviousPage,
//     hasNextPage,
//     totalCount,
//     authorizations: state.authorizations
//   }
// }

// const mapDispatchToProps = (dispatch) => ({
//   actions: bindActionCreators(actions, dispatch),
//   authActions: bindActionCreators(authActions, dispatch)
// })

// export default connect(mapStateToProps, mapDispatchToProps)(ChannelIndex)
