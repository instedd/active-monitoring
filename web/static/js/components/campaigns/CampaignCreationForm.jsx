import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import { connect } from 'react-redux'
// import { withRouter } from 'react-router'
import { ScrollToLink, animatedScrollTo } from '../ScrollToLink'
import SymptomStep from './SymptomStep'
import LanguageStep from './LanguageStep'
import UploadAudioStep from './UploadAudioStep'
import EducationalInformationStep from './EducationalInformationStep'
import SelectChannelStep from './SelectChannelStep'
import List from 'react-md/lib/Lists/List'
import ListItem from 'react-md/lib/Lists/ListItem'
import FontIcon from 'react-md/lib/FontIcons'

export default class CampaignCreationForm extends Component {
  // componentDidMount() {
  //   window.scrollTo(0, 0)
  //   $('.scrollspy').scrollSpy()
  //   const sidebar = $(this.refs.sidebar)
  //   sidebar.pushpin({ top: sidebar.offset().top, offset: 60 })
  // }

  // launchSurvey() {
  //   const { projectId, surveyId, router } = this.props
  //   launchSurvey(projectId, surveyId)
  //     .then(() => router.push(routes.survey(projectId, surveyId)))
  // }

  completedSymptomStep() {
    return this.props.campaign.symptoms.length > 0 && this.props.campaign.forwardingNumber != null
  }

  completedAudioStep() {
    return false
  }

  completedEducationalInformationStep() {
    return this.props.campaign.additionalInformation != null
  }

  completedLanguageStep() {
    return this.props.campaign.langs.length > 0
  }

  render() {
    // const { survey, projectId, questionnaires, channels, respondentGroups, respondentGroupsUploading, respondentGroupsUploadingExisting, invalidRespondents, invalidGroup, errors, questionnaire, readOnly } = this.props

    const steps = [this.completedSymptomStep(), this.completedAudioStep(), this.completedEducationalInformationStep(), this.completedLanguageStep()]
    const numberOfCompletedSteps = steps.filter(item => item == true).length
    const percentage = `${(100 / steps.length * numberOfCompletedSteps).toFixed(0)}%`

    // let launchComponent = null
    // if (survey.state == 'ready' && !readOnly) {
    //   launchComponent = (
    //     <Tooltip text='Launch survey'>
    //       <a className='btn-floating btn-large waves-effect waves-light green right mtop' style={{top: '90px', left: '-5%'}} onClick={() => this.launchSurvey()}>
    //         <i className='material-icons'>play_arrow</i>
    //       </a>
    //     </Tooltip>
    //   )
    // }

    // We make most steps to be "read only" (that is, non-editable) if the server said that survey
    // is "read only" (this is for a reader user) or if the survey has already started (in which
    // case there's no point in choosing a different questionnaire and so on).
    //
    // However, for the respondents step we distinguish between "read only" and "survey started",
    // because a non-reader user can still add more respondents to an existing survey, though
    // she can, for example, change their channel.
    // const surveyStarted = survey.state == 'running' || survey.state == 'terminated'

    let completed = false

    return (
      <div className='md-grid'>
        <div className='md-cell md-paper md-paper--1'>
          <h5>Progress <span className='right'>{percentage}</span></h5>
          <p>
            Complete the following tasks to get your Campaign ready.
          </p>
          <div className='progress'>
            <div className='determinate' style={{ width: percentage }} />
          </div>
          <List className='wizard'>
            <ListItem onClick={(e) => animatedScrollTo(e, 'identification')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'assignment'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Set up identification process' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'symptoms')} leftIcon={<FontIcon>{this.completedSymptomStep() ? 'check_circle' : 'healing'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Define the symptoms' className={this.completedSymptomStep() ? 'md-text-green' : ''} />
            <ListItem onClick={(e) => animatedScrollTo(e, 'information')} leftIcon={<FontIcon>{this.completedEducationalInformationStep() ? 'check_circle' : 'info'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Educational information' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'languages')} leftIcon={<FontIcon>{this.completedLanguageStep() ? 'check_circle' : 'translate'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Select languages' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'audios')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'volume_up'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Upload audios' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'select-channel')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'settings_input_antenna'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Select channel' />
          </List>
        </div>
        <div className='md-cell md-cell--8 wizard-content'>
          <div id='identification'>
            <ScrollToLink target='#identification'>NEXT: Define the symptoms</ScrollToLink>
          </div>
          <div id='symptoms'>
            <SymptomStep />
            <ScrollToLink target='#symptoms'>NEXT: Educational information</ScrollToLink>
          </div>
          <div id='information'>
            <EducationalInformationStep />
            <ScrollToLink target='#information'>NEXT: Setup a Schedule</ScrollToLink>
          </div>
          <div id='languages'>
            <LanguageStep />
            <ScrollToLink target='#audios'>NEXT: Upload audio files</ScrollToLink>
          </div>
          <div id='audios'>
            <UploadAudioStep />
            <ScrollToLink target='#select-channel'>NEXT: Select channel</ScrollToLink>
          </div>
          <div id='select-channel'>
            <SelectChannelStep />
          </div>
        </div>
      </div>
    )
  }
}

CampaignCreationForm.propTypes = {
  campaign: PropTypes.object
}

// const mapStateToProps = (state) => ({
//   campaign: state.campaign.data,
//   campaignId: state.campaignId
// })
