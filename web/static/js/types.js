// @flow
export type Step = string
export type LanguageCode = string
export type Uuid = string
export type Audio = [Step, LanguageCode, Uuid]
export type Campaign = {
  audios: Audio[],
  langs: string[],
  symptoms: string[][],
  additionalInformation: ?string,
};
