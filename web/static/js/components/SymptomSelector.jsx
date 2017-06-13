import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { addEmptySymptom, editSymptom, removeSymptom } from '../actions/symptoms'
import Button from 'react-md/lib/Buttons/Button'
import List from 'react-md/lib/Lists/List'
import ListItem from 'react-md/lib/Lists/ListItem'
import EditableTitleLabel from './EditableTitleLabel'
import FontIcon from 'react-md/lib/FontIcons'

class SymptomSelectorComponent extends Component {
  render() {
    return (
      <div>
        <List>
          {this.props.symptoms.map((symptom, i) =>
            <ListItem
              key={i}
              rightIcon={<FontIcon onClick={() => this.props.onRemove(i)}>remove_circle</FontIcon>}
              primaryText={<EditableTitleLabel
                title={symptom}
                emptyText={'Insert symptom'}
                readOnly={false}
                onSubmit={(title) => this.props.onEdit(title, i)}
                hideEditingIcon />}
            />)}
        </List>
        <Button flat label='Add symptom' onClick={this.props.onAdd}>add</Button>
      </div>
    )
  }
}

SymptomSelectorComponent.propTypes = {
  symptoms: PropTypes.arrayOf(PropTypes.string),
  onRemove: PropTypes.func,
  onAdd: PropTypes.func,
  onEdit: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    symptoms: state.campaign.data.symptoms || []
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onAdd: () => dispatch(addEmptySymptom()),
    onEdit: (symptom, index) => dispatch(editSymptom(symptom, index)),
    onRemove: (index) => dispatch(removeSymptom(index))
  }
}

const SymptomSelector = connect(
  mapStateToProps,
  mapDispatchToProps
)(SymptomSelectorComponent)

export default SymptomSelector
