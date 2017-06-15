import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import values from 'lodash/values'
import flatten from 'lodash/flatten'
import capitalize from 'lodash/capitalize'

// import { campaignUpdate } from '../../actions/campaign'
import { audioEntries, getAudioFileFor } from '../../selectors/campaign'
import { uploadCampaignAudio } from '../../actions/audios'
import { codeToName } from '../../langs'

import FontIcon from 'react-md/lib/FontIcons'
import Tabs from 'react-md/lib/Tabs/Tabs'
import Tab from 'react-md/lib/Tabs/Tab'
import TabsContainer from 'react-md/lib/Tabs/TabsContainer'

import AudioPicker from '../AudioPicker'

const AudiosUploadedCounter = ({uploaded, total}) => (
  <div className='md-cell md-cell--12'>
    <FontIcon>volume_up</FontIcon>
    <span>{uploaded}/{total} audio files uploaded</span>
  </div>
)

AudiosUploadedCounter.propTypes = {
  uploaded: PropTypes.number.isRequired,
  total: PropTypes.number.isRequired
}

class UploadAudioStepComponent extends Component {
  getTopicTexts(topic) {
    if (topic == 'welcome') {
      return { title: 'Welcome message', description: 'Present the objectives of this call' }
    } else if (topic == 'forward') {
      return { title: 'Forward call message', description: 'Explain that the current call will be forwarded to an agent due to positive symptoms' }
    } else if (topic == 'educational') {
      return { title: 'Educational information', description: 'Inform the caller about additional information such as prevention measures' }
    } else if (topic == 'thanks') {
      return { title: 'Thank you message', description: 'Thank the caller for participating' }
    } else if (topic == 'language') {
      const description = this.props.langs.map((iso, i) => `${i + 1} for ${codeToName(iso)}`).join(', ')
      return { title: 'Language options', description: `List the options: ${description}` }
    } else if (topic.startsWith('symptom:')) {
      const id = topic.split(':', 2)[1]
      const name = this.props.symptoms.find(([_id, _name]) => id == _id)[1]
      return { title: `${capitalize(name)} symptom question`, description: 'Ask if there are any signs of this symptom: 1 for Yes, 2 for No' }
    } else {
      throw new Error(`Unexpected topic: ${topic}`)
    }
  }

  renderLangTab(lang) {
    return (
      <Tab label={codeToName(lang)} key={lang}>
        {this.props.entries[lang].map(topic => (
          <AudioPicker
            file={getAudioFileFor(this.props.audios, topic, lang)}
            onUpload={(file) => this.props.onUploadAudio(file, topic, lang)}
            key={topic}
            {...this.getTopicTexts(topic)} />
        ))}
      </Tab>
    )
  }

  render() {
    const totalAudios = flatten(values(this.props.entries)).length + 1

    return (
      <div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h3>Upload audio files</h3>
            <p>
              Upload an audio file for each message. After that you will be able to test the call flow.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <AudiosUploadedCounter uploaded={this.props.audios.length} total={totalAudios} />
          <AudioPicker onUpload={(file) => this.props.onUploadAudio(file, 'language')} file={getAudioFileFor(this.props.audios, 'language', null)} {...this.getTopicTexts('language')} />
          <TabsContainer panelClassName='md-grid'>
            <Tabs tabId='langs'>
              {this.props.langs.map(lang => this.renderLangTab(lang))}
            </Tabs>
          </TabsContainer>
        </div>
      </div>
    )
  }
}

UploadAudioStepComponent.propTypes = {
  langs: PropTypes.arrayOf(PropTypes.string),
  symptoms: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.string)),
  entries: PropTypes.object,
  audios: PropTypes.array,
  onUploadAudio: PropTypes.func
}

const mapStateToProps = (state) => {
  return {
    entries: audioEntries(state),
    audios: state.campaign.data.audios || [],
    symptoms: state.campaign.data.symptoms,
    langs: state.campaign.data.langs || ['en', 'es']
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onUploadAudio: (file, topic, language) => dispatch(uploadCampaignAudio(file, topic, language))
  }
}

const UploadAudioStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(UploadAudioStepComponent)

export default UploadAudioStep
