import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { campaignUpdate } from '../../actions/campaign'
import Radio from 'react-md/lib/SelectionControls/Radio'

class EducationalInformationComponent extends Component {
  render() {
    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h4>Educational information</h4>
            <p className='flow-text'>
              In case of asymptomatic subjects you can offer additional information to prevent contagion after symptoms evaluation.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <fieldset>
              <Radio
                id='zero'
                name='zero'
                value='zero'
                label='No additional information'
                checked={this.props.additionalInformation === 'zero'}
                onChange={() => this.props.onEdit('zero')}
              />
              <Radio
                id='optional'
                name='optional'
                value='optional'
                label='Optional additional information'
                checked={this.props.additionalInformation === 'optional'}
                onChange={() => this.props.onEdit('optional')}
              />
              <Radio
                id='compulsory'
                name='compulsory'
                value='compulsory'
                label='Compulsory additional information'
                checked={this.props.additionalInformation === 'compulsory'}
                onChange={() => this.props.onEdit('compulsory')}
              />
            </fieldset>
          </div>
        </div>
      </div>
    )
  }
}

EducationalInformationComponent.propTypes = {
  additionalInformation: PropTypes.string,
  onEdit: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    additionalInformation: state.campaign.data.additionalInformation
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onEdit: (additionalInformation) => dispatch(campaignUpdate({additionalInformation: additionalInformation}))
  }
}

const EducationalInformationStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(EducationalInformationComponent)

export default EducationalInformationStep
