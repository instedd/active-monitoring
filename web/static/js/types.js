// @flow
export type Step = string
export type LanguageCode = string
export type Uuid = string
export type Audio = [Step, LanguageCode, Uuid]
export type Timezone = string
export type Campaign = {
  id: number,
  audios: Audio[],
  langs: string[],
  symptoms: string[][],
  additionalInformation: ?string,
  timezone: Timezone,
  forwardingNumber: ?string,
  monitorDuration: ?number,
  channel: ?string,
}

export type Subject = {
  id: number,
  phoneNumber: string,
  registrationIdentifier: string,
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
