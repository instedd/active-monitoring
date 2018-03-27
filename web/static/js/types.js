// @flow
export type Mode = 'call' | 'chat'
export type Step = string
export type LanguageCode = string
export type Message = {
  step: Step,
  language: ?LanguageCode,
  mode: Mode,
  value: string
}
export type Timezone = string

export type Campaign = {
  id: number,
  name: ?string,
  langs: string[],
  symptoms: string[][],
  additionalInformation: ?string,
  timezone: Timezone,
  monitorDuration: ?number,
  forwardingContact: ?string,
  channel: ?string,
  mode: Mode,
  messages: Message[]
}

export type Subject = {
  id: number,
  phoneNumber: string,
  registrationIdentifier: string,
  enrollDate: Date,
  firstCallDate: ?Date,
  lastCallDate: ?Date,
  lastSuccessfulCallDate: ?Date,
  activeCase: boolean,
}

export type SubjectParams = {
  id?: number,
  phoneNumber: string,
  registrationIdentifier: string,
}

export type State = {
  timezones: {
    fetching: boolean
  },
  subjects: {
    editingSubject: Subject,
    targetPage: number
  },
  campaign: Campaign
}

export type Items = {
  subjects: Subject[],
  count: number
}

export type Action = {
  type: string,
}

export type Dispatch = (action: Action | Function) => void
export type GetState = () => State
