// @flow
import { connect } from 'react-redux'
import React, { Component } from 'react'
import values from 'lodash/values'
import flatten from 'lodash/flatten'
import capitalize from 'lodash/capitalize'

import type { LanguageCode, Step } from '../../types'

import { messagesInUse, neededMessages, getChatTextFor } from '../../selectors/campaign'
import { codeToName } from '../../langs'

import FontIcon from 'react-md/lib/FontIcons'
import Tabs from 'react-md/lib/Tabs/Tabs'
import Tab from 'react-md/lib/Tabs/Tab'
import TabsContainer from 'react-md/lib/Tabs/TabsContainer'
import ChatText from '../ChatText'

const MessageTextCounter = ({filled, total}) => (
  <div className='md-cell md-cell--12'>
    <h3 className='uploaded-files'>
      <FontIcon>note_add</FontIcon>
      {filled}/{total} texts filled
    </h3>
  </div>
)

type ChatTextStepProps = {
  children: any,
  langs: string[],
  symptoms: string[][],
  neededMessages: { [lang: string]: string[] },
  messages: string[][],
  onAddChatText: (text: string, step: Step, language: ?LanguageCode) => void,
  onRemoveChatText: (step: Step, language: ?LanguageCode) => void
}

class ChatTextStepComponent extends Component<ChatTextStepProps> {
  getTopicTexts(topic) {
    if (topic == 'welcome') {
      return { title: 'Welcome message', description: 'Present the objectives of this chat bot' }
    } else if (topic == 'identify') {
      return { title: 'Identify message', description: 'Ask subject to enter their ID or request it if they do not have one' }
    } else if (topic == 'registration') {
      return { title: 'Registration message', description: 'Inform the subject to send "registration" to register to the campaign' }
    } else if (topic == 'educational') {
      return { title: 'Educational information', description: 'Inform the subject about additional information such as prevention measures' }
    } else if (topic == 'additional_information_intro') {
      return { title: 'Additional information introduction', description: 'Ask the subject whether they want to read some educational information' }
    } else if (topic == 'thanks') {
      return { title: 'Thank you message', description: 'Thank the subject for participating' }
    } else if (topic == 'language') {
      return { title: 'Language options', description: '' }
    } else if (topic.startsWith('symptom:')) {
      const id = topic.split(':', 2)[1]
      const matchingSymptom = this.props.symptoms.find(([_id, _name]) => id == _id)

      if (Array.isArray(matchingSymptom)) {
        return { title: `${capitalize(matchingSymptom[1])} symptom question`, description: 'Ask if there are any signs of this symptom.' }
      } else {
        throw new Error(`Malformed symptom list`)
      }
    } else {
      throw new Error(`Unexpected topic: ${topic}`)
    }
  }

  renderLangTab(lang) {
    const { neededMessages, messages } = this.props

    return (
      <Tab label={codeToName(lang)} key={lang}>
        {neededMessages[lang].map(topic => (
          <ChatText
            text={getChatTextFor(messages, topic, lang)}
            step={topic}
            language={lang}
            key={topic}
            {...this.getTopicTexts(topic)}
          />
        ))}
      </Tab>
    )
  }

  render() {
    const { neededMessages, messages } = this.props

    const totalCopies = flatten(values(neededMessages)).length + 1

    return (
      <section id='audios' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Add Chatbot texts</h1>
            <p>
              Add the text for each chat message. After that you will be able to test the chat flow.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <MessageTextCounter filled={messages.length} total={totalCopies} />
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <ChatText
              step={'language'}
              language={''}
              text={getChatTextFor(messages, 'language', '')}
              {...this.getTopicTexts('language')}
            />
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

const mapStateToProps = (state, ownProps) => {
  const campaign = ownProps.campaign
  return {
    messages: messagesInUse(campaign),
    neededMessages: neededMessages(campaign),
    symptoms: campaign.symptoms || [],
    langs: campaign.langs || []
  }
}

const ChatTextStep = connect(
  mapStateToProps
)(ChatTextStepComponent)

export default ChatTextStep
