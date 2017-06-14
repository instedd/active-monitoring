import { campaignUpdate } from './campaign'

export const EMPTY_SYMPTOM_ADD = 'EMPTY_SYMPTOM_ADD'

export const addEmptySymptom = () => {
  return { type: EMPTY_SYMPTOM_ADD }
}

export const editSymptom = (newName, index) => (dispatch, getState) => {
  let symptoms = getState().campaign.data.symptoms.slice()
  let [id, name] = symptoms[index]
  symptoms[index] = [id, newName]
  dispatch(campaignUpdate({symptoms}))
}

export const removeSymptom = (index) => (dispatch, getState) => {
  let symptoms = getState().campaign.data.symptoms.slice()
  symptoms.splice(index, 1)
  dispatch(campaignUpdate({symptoms}))
}
