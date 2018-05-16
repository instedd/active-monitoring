// @flow
import { connect } from 'react-redux'
import React, { Component, type Node } from 'react'
import { addEmptySymptom, editSymptom, removeSymptom } from '../../actions/symptoms'
import { campaignUpdate } from '../../actions/campaign'
import SelectField from 'react-md/lib/SelectFields'
import TextField from '../TextField'
import Button from 'react-md/lib/Buttons/Button'
import List from 'react-md/lib/Lists/List'
import ListItem from 'react-md/lib/Lists/ListItem'
import EditableTitleLabel from '../EditableTitleLabel'
import FontIcon from 'react-md/lib/FontIcons'
import type { Campaign, Mode } from '../../types'

type Props = {
  campaign: Campaign,
  onRemove: number => void,
  onAdd: () => void,
  onEdit: (string, number) => void,
  onEditForwarding: (string, string) => void,
  children: Node
}

class SymptomStepComponent extends Component<Props> {
  symptomsCopy(mode: Mode): string {
    let copy = 'upload audio'
    if (mode === 'chat') {
      copy = 'enter texts'
    }
    return `The symptoms will be used to evaluate positive cases of the disease and send alerts to responders. Later you will be asked to ${copy} explaining how to evaluate these symptoms.`
  }

  forwardConditionCopy(mode: Mode, option: 'all' | 'any'): {value: string, label: string} {
    let action = 'Forward call'
    let condition = 'any symptom is'

    if (mode === 'chat') {
      action = 'Contact responder'
    }

    if (option === 'all') {
      condition = 'all symptoms are'
    }

    return {value: option, label: `${action} if ${condition} positive`}
  }

  forwardAddressLabel(mode: Mode): string {
    if (mode === 'chat') {
      return 'Contact email address'
    } else {
      return 'Forward number'
    }
  }

  render() {
    const { campaign } = this.props

    return (
      <section id='symptoms' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Define the symptoms</h1>
            <p>
              {this.symptomsCopy(campaign.mode)}
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <SelectField
            id='forwarding-condition'
            menuItems={[this.forwardConditionCopy(campaign.mode, 'any'), this.forwardConditionCopy(campaign.mode, 'all')]}
            className='md-cell md-cell--8  md-cell--bottom'
            value={campaign.forwardingCondition || 'any'}
            onChange={(val) => this.props.onEditForwarding('forwardingCondition', val)}
          />
          <TextField
            id='forwarding-address'
            label={this.forwardAddressLabel(campaign.mode)}
            className='md-cell md-cell--4'
            defaultValue={campaign.forwardingAddress || ''}
            onSubmit={(val) => this.props.onEditForwarding('forwardingAddress', val)}
          />
        </div>
        <div className='md-grid'>
          <List className='md-cell md-cell--12'>
            {campaign.symptoms.map(([id, name], i) =>
              <ListItem
                key={id}
                rightIcon={<FontIcon onClick={() => this.props.onRemove(i)}>remove_circle</FontIcon>}
                primaryText={<EditableTitleLabel
                  title={name}
                  emptyText={'Insert symptom'}
                  readOnly={false}
                  onSubmit={(title) => this.props.onEdit(title, i)}
                  hideEditingIcon />}
              />)}
          </List>
          <Button flat label='Add symptom' className='btn-add-grey' onClick={this.props.onAdd}>add</Button>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            {this.props.children}
          </div>
        </div>
      </section>
    )
  }
}

const mapStateToProps = (state, ownProps) => {
  return {
    campaign: ownProps.campaign
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onAdd: () => dispatch(addEmptySymptom()),
    onEdit: (symptom, index) => dispatch(editSymptom(symptom, index)),
    onRemove: (index) => dispatch(removeSymptom(index)),
    onEditForwarding: (key, value) => dispatch(campaignUpdate({[key]: value}))
  }
}

const SymptomStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(SymptomStepComponent)

export default SymptomStep
