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
};

export type State = {
  timezones: {
    fetching: boolean,
  }
}

export type Action = {
  type: string,
}

export type Dispatch = (action: Action) => void
export type GetState = () => State
