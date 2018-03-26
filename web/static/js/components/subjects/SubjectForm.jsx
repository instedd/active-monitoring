// @flow
import React, { Component } from 'react'
import TextField from 'react-md/lib/TextFields'
import Button from 'react-md/lib/Buttons'
import type {SubjectParams} from '../../types'

type Props = {
  onEditRegistrationIdentifier: (registrationIdentifier: string) => void,
  onEditPhoneNumber: (phoneNumber: string) => void,
  onSubmit: () => void,
  onCancel: () => void,
  subject: SubjectParams
}
class SubjectForm extends Component<Props> {
  render() {
    const { subject, onSubmit, onCancel, onEditPhoneNumber, onEditRegistrationIdentifier } = this.props

    return (
      <section id='subject'>
        <div className='md-grid'>
          <TextField
            id='registration-identifier'
            label='ID'
            className='md-cell md-cell--12'
            defaultValue={subject.registrationIdentifier || ''}
            onBlur={e => onEditRegistrationIdentifier(e.target.value)}
          />
          <TextField
            id='phone-number'
            label='Phone Number'
            className='md-cell md-cell--12'
            defaultValue={subject.phoneNumber || ''}
            onBlur={e => onEditPhoneNumber(e.target.value)}
          />
        </div>
        <div className='md-grid'>
          <Button primary className='md-cell' onClick={onSubmit} raised label='Save' />
          <Button secondary className='md-cell' onClick={onCancel} flat label='Cancel' />
        </div>
      </section>
    )
  }
}

export default SubjectForm
