// @flow
import React, { Component } from 'react'
import TextField from 'react-md/lib/TextFields'
import Button from 'react-md/lib/Buttons'
import type {SubjectParams} from '../../types'

class SubjectForm extends Component {
  props: {
    onEditRegistrationIdentifier: (registrationIdentifier: string) => void,
    onEditPhoneNumber: (phoneNumber: string) => void,
    onSubmit: () => void,
    onCancel: () => void,
    subject: SubjectParams
  }

  render() {
    const { subject, onSubmit, onCancel, onEditPhoneNumber, onEditRegistrationIdentifier } = this.props

    return (
      <section id='subject'>
        <div>
          <TextField
            id='registration-identifier'
            label='ID'
            defaultValue={subject.registrationIdentifier || ''}
            onBlur={e => onEditRegistrationIdentifier(e.target.value)}
          />
          <TextField
            id='phone-number'
            label='Phone Number'
            defaultValue={subject.phoneNumber || ''}
            onBlur={e => onEditPhoneNumber(e.target.value)}
          />
          <Button primary onClick={onSubmit} raised label='Save' />
          <Button secondary onClick={onCancel} flat label='Cancel' />
        </div>
      </section>
    )
  }
}

export default SubjectForm
