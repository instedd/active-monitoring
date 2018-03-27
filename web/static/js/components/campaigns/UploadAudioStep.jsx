// @flow
import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import values from 'lodash/values'
import flatten from 'lodash/flatten'
import capitalize from 'lodash/capitalize'

import type { LanguageCode, Message, Step } from '../../types'

import { messagesInUse, neededMessages, getAudioFileFor } from '../../selectors/campaign'
import { uploadCampaignAudio, removeCampaignAudio } from '../../actions/audios'
import { codeToName } from '../../langs'

import FontIcon from 'react-md/lib/FontIcons'
import Tabs from 'react-md/lib/Tabs/Tabs'
import Tab from 'react-md/lib/Tabs/Tab'
import TabsContainer from 'react-md/lib/Tabs/TabsContainer'

import AudioPicker from '../AudioPicker'

const AudiosUploadedCounter = ({uploaded, total}) => (
  <div className='md-cell md-cell--12'>
    <h3 className='uploaded-files'>
      <FontIcon>volume_up</FontIcon>
      {uploaded}/{total} audio files uploaded
    </h3>
  </div>
)

AudiosUploadedCounter.propTypes = {
  uploaded: PropTypes.number.isRequired,
  total: PropTypes.number.isRequired
}

type UploadAudioStepProps = {
  children: any,
  langs: string[],
  symptoms: string[][],
  neededMessages: { [lang: string]: string[] },
  messages: Message[],
  onUploadAudio: (file: string, step: Step, language: ?LanguageCode) => void,
  onRemoveAudio: (step: Step, language: ?LanguageCode) => void
}

class UploadAudioStepComponent extends Component<UploadAudioStepProps> {
  getTopicTexts(topic) {
    if (topic == 'welcome') {
      return { title: 'Welcome message', description: 'Present the objectives of this call' }
    } else if (topic == 'identify') {
      return { title: 'Identify message', description: 'Ask subject to dial their ID or to press # if they do not have one' }
    } else if (topic == 'registration') {
      return { title: 'Registration message', description: 'Inform the caller the call will be forwarded to an agent for registration' }
    } else if (topic == 'forward') {
      return { title: 'Forward call message', description: 'Explain that the current call will be forwarded to an agent due to positive symptoms' }
    } else if (topic == 'educational') {
      return { title: 'Educational information', description: 'Inform the caller about additional information such as prevention measures' }
    } else if (topic == 'additional_information_intro') {
      return { title: 'Additional information introduction', description: 'Ask the caller whether they want to listen to educational information: 1 for Yes, 3 for No' }
    } else if (topic == 'thanks') {
      return { title: 'Thank you message', description: 'Thank the caller for participating' }
    } else if (topic == 'language') {
      const description = this.props.langs.map((iso: string, i) => {
        const countryName = codeToName(iso) || 'unknown country'
        return `${i + 1} for ${countryName}`
      }).join(', ')
      return { title: 'Language options', description: `List the options: ${description}` }
    } else if (topic.startsWith('symptom:')) {
      const id = topic.split(':', 2)[1]
      const matchingSymptom = this.props.symptoms.find(([_id, _name]) => id == _id)

      if (Array.isArray(matchingSymptom)) {
        return { title: `${capitalize(matchingSymptom[1])} symptom question`, description: 'Ask if there are any signs of this symptom: 1 for Yes, 3 for No' }
      } else {
        throw new Error(`Malformed symptom list`)
      }
    } else {
      throw new Error(`Unexpected topic: ${topic}`)
    }
  }

  renderLangTab(lang) {
    const { neededMessages, messages, onUploadAudio, onRemoveAudio } = this.props

    return (
      <Tab label={codeToName(lang)} key={lang}>
        {neededMessages[lang].map(topic => (
          <AudioPicker
            file={getAudioFileFor(messages, topic, lang)}
            onUpload={(file) => onUploadAudio(file, topic, lang)}
            onRemove={() => onRemoveAudio(topic, lang)}
            key={topic}
            {...this.getTopicTexts(topic)} />
        ))}
      </Tab>
    )
  }

  render() {
    const { neededMessages } = this.props

    const totalAudios = flatten(values(neededMessages)).length + 1

    return (
      <section id='audios' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Upload audio files</h1>
            <p>
              Upload an audio file for each message. After that you will be able to test the call flow.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <AudiosUploadedCounter uploaded={neededMessages.length} total={totalAudios} />
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <AudioPicker
              onUpload={(file) => this.props.onUploadAudio(file, 'language')}
              onRemove={() => this.props.onRemoveAudio('language')}
              file={getAudioFileFor(this.props.messages, 'language')}
              {...this.getTopicTexts('language')} />
          </div>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <TabsContainer component={'div'} panelClassName='md-grid'>
              <Tabs tabId='langs'>
                {this.props.langs.filter(lang => lang && lang != '').map(lang => this.renderLangTab(lang))}
              </Tabs>
            </TabsContainer>
          </div>
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

const mapStateToProps = (state) => {
  return {
    messages: messagesInUse(state.campaign.data),
    neededMessages: neededMessages(state.campaign.data),
    symptoms: state.campaign.data.symptoms,
    langs: state.campaign.data.langs || []
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onUploadAudio: (file, topic, language) => dispatch(uploadCampaignAudio(file, topic, language)),
    onRemoveAudio: (topic, language) => dispatch(removeCampaignAudio(topic, language))
  }
}

const UploadAudioStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(UploadAudioStepComponent)

export default UploadAudioStep
