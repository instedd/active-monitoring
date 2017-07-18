import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { ScrollToLink, animatedScrollTo } from '../ScrollToLink'
import PositionFixer from '../PositionFixer'
import SymptomStep from './SymptomStep'
import LanguageStep from './LanguageStep'
import UploadAudioStep from './UploadAudioStep'
import EducationalInformationStep from './EducationalInformationStep'
import { campaignLaunch } from '../../actions/campaign'
import List from 'react-md/lib/Lists/List'
import ListItem from 'react-md/lib/Lists/ListItem'
import FontIcon from 'react-md/lib/FontIcons'
import Subheader from 'react-md/lib/Subheaders'
import Button from 'react-md/lib/Buttons'

class CampaignCreationFormComponent extends Component {
  completedSymptomStep() {
    return this.props.campaign.symptoms.length > 0 && this.props.campaign.forwardingNumber != null
  }

  completedAudioStep() {
    return true
  }

  completedEducationalInformationStep() {
    return this.props.campaign.additionalInformation != null
  }

  completedLanguageStep() {
    return this.props.campaign.langs.length > 0
  }

  render() {
    const steps = [this.completedSymptomStep(), this.completedAudioStep(), this.completedEducationalInformationStep(), this.completedLanguageStep()]
    const numberOfCompletedSteps = steps.filter(item => item == true).length
    const percentage = `${(100 / steps.length * numberOfCompletedSteps).toFixed(0)}%`

    let launchComponent = null
    if (numberOfCompletedSteps == steps.length) {
      launchComponent = (
        <Button floating secondary
          tooltipLabel='Launch campaign'
          tooltipPosition='top'
          className='launch-campaign'
          onClick={() => this.props.launchCampaign(this.props.campaign.id)}>play_arrow</Button>
      )
    }

    let completed = false

    return (
      <div className='md-grid white'>
        <div className='md-cell md-cell--12-tablet md-cell--4-desktop md-cell--tablet-hidden '>
          <PositionFixer offset={60}>
            <div className='md-paper md-paper--1 rounded-corners'>
              <List className='wizard'>
                <Subheader primaryText={<p>Complete the following tasks to get your Campaign ready.</p>}>
                  <h2>Progress <span className='right'>{percentage}</span></h2>
                  <div className='progress'>
                    <div className='determinate' style={{ width: percentage }} />
                  </div>
                  {launchComponent}
                </Subheader>
                <ListItem onClick={(e) => animatedScrollTo(e, 'identification')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'assignment'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Set up identification process' />
                <ListItem onClick={(e) => animatedScrollTo(e, 'symptoms')} leftIcon={<FontIcon>{this.completedSymptomStep() ? 'check_circle' : 'healing'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Define the symptoms' className={this.completedSymptomStep() ? 'md-text-green' : ''} />
                <ListItem onClick={(e) => animatedScrollTo(e, 'information')} leftIcon={<FontIcon>{this.completedEducationalInformationStep() ? 'check_circle' : 'info'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Educational information' />
                <ListItem onClick={(e) => animatedScrollTo(e, 'languages')} leftIcon={<FontIcon>{this.completedLanguageStep() ? 'check_circle' : 'translate'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Select languages' />
                <ListItem onClick={(e) => animatedScrollTo(e, 'audios')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'volume_up'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Upload audios' />
              </List>
            </div>
          </PositionFixer>
        </div>
        <div className='md-cell md-cell--12-tablet md-cell--7-desktop md-cell--1-desktop-offset wizard-content'>
          <section id='identification'>
            <h1> Set up identification process</h1>
            <ScrollToLink target='#symptoms'>NEXT: Define the symptoms</ScrollToLink>
          </section>
          <SymptomStep>
            <ScrollToLink target='#information'>NEXT: Educational information</ScrollToLink>
          </SymptomStep>
          <EducationalInformationStep>
            <ScrollToLink target='#languages'>NEXT: Setup a Schedule</ScrollToLink>
          </EducationalInformationStep>
          <LanguageStep>
            <ScrollToLink target='#audios'>NEXT: Upload audio files</ScrollToLink>
          </LanguageStep>
          <UploadAudioStep />
        </div>
      </div>
    )
  }
}

CampaignCreationFormComponent.propTypes = {
  campaign: PropTypes.object,
  launchCampaign: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    campaign: state.campaign.data
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    launchCampaign: (id) => dispatch(campaignLaunch(id))
  }
}

const CampaignCreationForm = connect(
  mapStateToProps,
  mapDispatchToProps
)(CampaignCreationFormComponent)

export default CampaignCreationForm
