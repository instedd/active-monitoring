import 'isomorphic-fetch'

export class Unauthorized {
  constructor(response) {
    this.response = response
  }
}

const apiFetch = (url, options) => {
  return fetch(`/api/v1/${url}`, { ...options, credentials: 'same-origin' })
    .then(response => {
      return handleResponse(response, () =>
        response)
    })
}

const apiFetchJSON = (url, options) => {
  return apiFetchJSONWithCallback(url, options, commonCallback)
}

const apiFetchJSONWithCallback = (url, options, responseCallback) => {
  return apiFetch(url, options)
    .then(response => {
      if (response.status == 204) {
        // HTTP 204: No Content
        return { json: null, response }
      } else {
        return response.json().then(json => ({ json, response }))
      }
    })
    .then(({ json, response }) => {
      return handleResponse(response, responseCallback(json))
    })
}

const commonCallback = (json) => {
  return () => {
    if (!json) { return null }
    if (json.errors) {
      console.log(json.errors)
    }
    return json.data
  }
}

const handleResponse = (response, callback) => {
  if (response.ok) {
    return callback()
  } else if (response.status == 401 || response.status == 403) {
    return Promise.reject(new Unauthorized(response.statusText))
  } else {
    return Promise.reject(response)
  }
}

const apiPutOrPostJSON = (url, verb, body) => {
  const options = {
    method: verb,
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  }
  if (body) {
    options.body = JSON.stringify(body)
  }
  return apiFetchJSON(url, options)
}

const apiPostJSON = (url, body) => {
  return apiPutOrPostJSON(url, 'POST', body)
}

const apiPutJSON = (url, body) => {
  return apiPutOrPostJSON(url, 'PUT', body)
}

const apiDelete = (url) => {
  return apiFetch(url, {method: 'DELETE'})
}

const apiPostFile = (url, file) => {
  return apiFetchJSON(url, {
    method: 'POST',
    body: newFormData(file)
  })
}

const newFormData = (file) => {
  const formData = new FormData()
  formData.append('file', file)
  return formData
}

export const createCampaign = (campaign) => {
  return apiPostJSON('campaigns', { campaign })
}

export const logout = (guissoLogoutUrl) => {
  apiDelete('sessions').then(() => { window.location.href = guissoLogoutUrl })
}

export const updateCampaign = (campaign) => {
  return apiPutJSON(`campaigns/${campaign.id}`, { campaign })
}

export const launchCampaign = (id) => {
  return apiPutJSON(`campaigns/${id}/launch`)
}

export const fetchCampaign = (id) => {
  return apiFetchJSON(`campaigns/${id}`)
}

export const fetchCampaigns = () => {
  return apiFetchJSON('campaigns')
}

export const fetchChannels = () => {
  return apiFetchJSON('channels')
}

export const fetchTimezones = () => {
  return apiFetchJSON('timezones')
}

export const fetchSubjects = (campaignId, limit, page) => {
  return apiFetchJSONWithCallback(`campaigns/${campaignId}/subjects/?limit=${limit}&page=${page}`, null, (json) => {
    return () => {
      if (!json) { return null }
      if (json.errors) {
        console.log(json.errors)
      }
      return {count: json.meta.count, subjects: json.data.subjects}
    }
  })
}

export const createSubject = (campaignId, subject) => {
  return apiPostJSON(`campaigns/${campaignId}/subjects`, { subject })
}

export const updateSubject = (campaignId, subject) => {
  return apiPutJSON(`campaigns/${campaignId}/subjects/${subject.id}`, { subject })
}

export const createAudio = (files) => {
  return apiPostFile('audios', files[0])
}

export const fetchAuthorizations = () => {
  return apiFetchJSONWithCallback(`authorizations`, null, (json, _) => () => json)
}

export const deleteAuthorization = (provider, baseUrl, keepChannels = false) => {
  return apiDelete(`authorizations/${provider}?base_url=${encodeURIComponent(baseUrl)}&keep_channels=${keepChannels}`)
}
