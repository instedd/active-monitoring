import React, { Component } from 'react'
import PropTypes from 'prop-types'
// import { connect } from 'react-redux'
// import { withRouter } from 'react-router'
import { ScrollToLink, animatedScrollTo } from '../ScrollToLink'
import SymptomStep from './SymptomStep'
import UploadAudioStep from './UploadAudioStep'
import List from 'react-md/lib/Lists/List'
import ListItem from 'react-md/lib/Lists/ListItem'
import FontIcon from 'react-md/lib/FontIcons'

export default class CampaignCreationForm extends Component {
  // static propTypes = {
  //   projectId: PropTypes.any.isRequired,
  //   survey: PropTypes.object.isRequired,
  //   surveyId: PropTypes.any.isRequired,
  //   router: PropTypes.object.isRequired,
  //   questionnaires: PropTypes.object,
  //   questionnaire: PropTypes.object,
  //   respondentGroups: PropTypes.object,
  //   respondentGroupsUploading: PropTypes.bool,
  //   respondentGroupsUploadingExisting: PropTypes.object,
  //   invalidRespondents: PropTypes.object,
  //   invalidGroup: PropTypes.bool,
  //   channels: PropTypes.object,
  //   errors: PropTypes.object,
  //   readOnly: PropTypes.bool.isRequired
  // }

  // componentDidMount() {
  //   window.scrollTo(0, 0)
  //   $('.scrollspy').scrollSpy()
  //   const sidebar = $(this.refs.sidebar)
  //   sidebar.pushpin({ top: sidebar.offset().top, offset: 60 })
  // }

  // allModesHaveAChannel(modes, channels) {
  //   const selectedTypes = channels.map(channel => channel.mode)
  //   modes = uniq(flatMap(modes))
  //   return modes.filter(mode => selectedTypes.indexOf(mode) != -1).length == modes.length
  // }

  // launchSurvey() {
  //   const { projectId, surveyId, router } = this.props
  //   launchSurvey(projectId, surveyId)
  //     .then(() => router.push(routes.survey(projectId, surveyId)))
  // }

  // questionnairesValid(ids, questionnaires) {
  //   return every(ids, id => questionnaires[id] && questionnaires[id].valid)
  // }

  // questionnairesMatchModes(modes, ids, questionnaires) {
  //   return every(modes, mode =>
  //     every(mode, m =>
  //       ids && every(ids, id =>
  //         questionnaires[id] && questionnaires[id].modes && questionnaires[id].modes.indexOf(m) != -1)))
  // }

  completedSymptomStep() {
    return this.props.campaign.symptoms.length > 0 && this.props.campaign.forwardingNumber != null
  }

  completedAudioStep() {

  }

  render() {
    // const { survey, projectId, questionnaires, channels, respondentGroups, respondentGroupsUploading, respondentGroupsUploadingExisting, invalidRespondents, invalidGroup, errors, questionnaire, readOnly } = this.props
    // const respondentsStepCompleted = respondentGroups && Object.keys(respondentGroups).length > 0 &&
    //   every(values(respondentGroups), group => {
    //     return group.channels.length > 0 && this.allModesHaveAChannel(survey.mode, group.channels)
    //   })

    // const modeStepCompleted = survey.mode != null && survey.mode.length > 0 && this.questionnairesMatchModes(survey.mode, survey.questionnaireIds, questionnaires)
    // const cutoffStepCompleted = survey.cutoff != null && survey.cutoff != ''
    // const validRetryConfiguration = !errors || (!errors.smsRetryConfiguration && !errors.ivrRetryConfiguration && !errors.fallbackDelay)
    // const scheduleStepCompleted =
    //   survey.scheduleDayOfWeek != null && (
    //     survey.scheduleDayOfWeek.sun ||
    //     survey.scheduleDayOfWeek.mon ||
    //     survey.scheduleDayOfWeek.tue ||
    //     survey.scheduleDayOfWeek.wed ||
    //     survey.scheduleDayOfWeek.thu ||
    //     survey.scheduleDayOfWeek.fri ||
    //     survey.scheduleDayOfWeek.sat
    //   ) && validRetryConfiguration
    // let comparisonsStepCompleted = false

    // const mandatorySteps = [questionnaireStepCompleted, respondentsStepCompleted, modeStepCompleted, scheduleStepCompleted]
    // if (survey.comparisons.length > 0) {
    //   comparisonsStepCompleted = sumBy(survey.comparisons, c => c.ratio) == 100
    //   mandatorySteps.push(comparisonsStepCompleted)
    // }

    // const numberOfCompletedSteps = mandatorySteps.filter(item => item == true).length
    // const percentage = `${(100 / mandatorySteps.length * numberOfCompletedSteps).toFixed(0)}%`

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
          <h5>Progress <span className='right'>{30}</span></h5>
          <p>
            Complete the following tasks to get your Campaign ready.
          </p>
          <div className='progress'>
            <div className='determinate' style={{ width: 30 }} />
          </div>
          <List className='wizard'>
            <ListItem onClick={(e) => animatedScrollTo(e, 'identification')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'assignment'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Set up identification process' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'symptoms')} leftIcon={<FontIcon>{this.completedSymptomStep() ? 'check_circle' : 'healing'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Define the symptoms' className={this.completedSymptomStep() ? 'md-text-green' : ''} />
            <ListItem onClick={(e) => animatedScrollTo(e, 'information')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'info'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Educational information' />
            <ListItem onClick={(e) => animatedScrollTo(e, 'audios')} leftIcon={<FontIcon>{completed ? 'check_circle' : 'volume_up'}</FontIcon>} rightIcon={<FontIcon>keyboard_arrow_right</FontIcon>} primaryText='Upload audios' />
          </List>
        </div>
        <div className='md-cell md-cell--8 wizard-content'>
          <div id='identification' className='row scrollspy'>
            <ScrollToLink target='#identification'>NEXT: Define the symptoms</ScrollToLink>
          </div>
          <div id='symptoms'>
            <SymptomStep />
            <ScrollToLink target='#symptoms'>NEXT: Educational information</ScrollToLink>
          </div>
          <div id='information' className='row scrollspy'>
            <div>
              <div className='row'>
                <div className='col s12'>
                  <h4>Educational information</h4>
                  <p className='flow-text'>
                    In case of asymptomatic subjects you can offer additional information to prevent contagion after symptoms evaluation.
                  </p>
                </div>
              </div>
            </div>
            <ScrollToLink target='#information'>NEXT: Setup a Schedule</ScrollToLink>
          </div>
          <div id='audios'>
            <UploadAudioStep />
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
