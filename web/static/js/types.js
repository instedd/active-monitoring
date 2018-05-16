// @flow
export type Mode = 'call' | 'chat'
export type Step = string
export type LanguageCode = string
export type Timezone = string

export type Campaign = {
  id: number,
  name: ?string,
  langs: string[],
  symptoms: string[][],
  forwardingAddress: ?string,
  forwardingCondition: ?string,
  additionalInformation: ?string,
  timezone: Timezone,
  monitorDuration: ?number,
  channel: ?string,
  fbPageId: ?string,
  fbVerifyToken: ?string,
  fbAccessToken: ?string,
  mode: Mode,
  chatTexts: string[][],
  audios: string[][]
}

export type Subject = {
  id: number,
  contactAddress: string,
  registrationIdentifier: string,
  enrollDate: Date,
  firstCallDate: ?Date,
  lastCallDate: ?Date,
  lastSuccessfulCallDate: ?Date,
  activeCase: boolean,
}

export type SubjectParams = {
  id?: number,
  contactAddress: string,
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
