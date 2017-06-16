import { campaignUpdate } from './campaign'

export const EMPTY_LANG_ADD = 'EMPTY_LANG_ADD'

export const addEmptyLang = () => {
  return { type: EMPTY_LANG_ADD }
}

export const editLang = (newName, index) => (dispatch, getState) => {
  let langs = getState().campaign.data.langs.slice()
  langs[index] = newName
  dispatch(campaignUpdate({langs}))
}

export const removeLang = (index) => (dispatch, getState) => {
  let langs = getState().campaign.data.langs.slice()
  langs.splice(index, 1)
  dispatch(campaignUpdate({langs}))
}
