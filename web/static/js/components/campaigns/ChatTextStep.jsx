// @flow
import { connect } from 'react-redux'
import React, { Component } from 'react'
import values from 'lodash/values'
import flatten from 'lodash/flatten'
import capitalize from 'lodash/capitalize'

import type { LanguageCode, Message, Step } from '../../types'

import { messagesInUse, neededMessages, getChatTextFor } from '../../selectors/campaign'
import { addCampaignChatText, removeCampaignChatText } from '../../actions/chat_texts'
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
  messages: Message[],
  onAddChatText: (text: string, step: Step, language: ?LanguageCode) => void,
  onRemoveChatText: (step: Step, language: ?LanguageCode) => void
}

class ChatTextStepComponent extends Component<ChatTextStepProps> {
  getTopicTexts(topic) {
    if (topic == 'welcome') {
      return { title: 'Welcome message', description: 'Present the objectives of this chat' }
    } else if (topic == 'identify') {
      return { title: 'Identify message', description: 'Ask subject to dial their ID or request it if they do not have one' }
    } else if (topic == 'registration') {
      return { title: 'Registration message', description: 'Inform the subject will be forwarded to an agent for registration' }
    } else if (topic == 'forward') {
      return { title: 'Forward call message', description: 'Explain that the current call will be forwarded to an agent due to positive symptoms' }
    } else if (topic == 'educational') {
      return { title: 'Educational information', description: 'Inform the caller about additional information such as prevention measures' }
    } else if (topic == 'additional_information_intro') {
      return { title: 'Additional information introduction', description: 'Ask the subject whether they want to talk about to educational information' }
    } else if (topic == 'thanks') {
      return { title: 'Thank you message', description: 'Thank the caller for participating' }
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
    const { neededMessages, messages, onAddChatText, onRemoveChatText } = this.props

    return (
      <Tab label={codeToName(lang)} key={lang}>
        {neededMessages[lang].map(topic => (
          <ChatText
            text={getChatTextFor(messages, topic, lang)}
            onAdd={(text) => onAddChatText(text, topic, lang)}
            onRemove={() => onRemoveChatText(topic, lang)}
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
            <h1>Add text messages</h1>
            <p>
              Add a text file for each message. After that you will be able to test the call flow.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <MessageTextCounter filled={messages.length} total={totalCopies} />
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <ChatText
              onAdd={(text) => this.props.onAddChatText(text, 'language')}
              onRemove={() => this.props.onRemoveChatText('language')}
              text={getChatTextFor(messages, 'language')}
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
    symptoms: campaign.symptoms,
    langs: campaign.langs || []
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onAddChatText: (text, topic, language) => dispatch(addCampaignChatText(text, topic, language)),
    onRemoveChatText: (topic, language) => dispatch(removeCampaignChatText(topic, language))
  }
}

const ChatTextStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(ChatTextStepComponent)

export default ChatTextStep
