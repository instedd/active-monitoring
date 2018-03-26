// @flow
import {bindActionCreators} from 'redux'
import {connect} from 'react-redux'
import React, {Component} from 'react'
import { NavLink } from 'react-router-dom'
import Card from 'react-md/lib/Cards/Card'
import DataTable from 'react-md/lib/DataTables/DataTable'
import TableHeader from 'react-md/lib/DataTables/TableHeader'
import TableBody from 'react-md/lib/DataTables/TableBody'
import TablePagination from 'react-md/lib/DataTables/TablePagination'
import TableRow from 'react-md/lib/DataTables/TableRow'
import TableColumn from 'react-md/lib/DataTables/TableColumn'
import Dialog from 'react-md/lib/Dialogs'
import CircularProgress from 'react-md/lib/Progress/CircularProgress'
import Button from 'react-md/lib/Buttons/Button'
import Moment from 'react-moment'

import * as collectionActions from '../../actions/subjects'
import * as itemActions from '../../actions/subject'
import * as campaignActions from '../../actions/campaign'
import EmptyListing from '../EmptyListing'
import SubjectForm from './SubjectForm'
import ActiveCampaignSubNav from '../ActiveCampaignSubNav'
import type { Subject, SubjectParams, Campaign } from '../../types'

type SubjectsListProps = {
  items: Subject[],
  showSubjectForm: () => void,
  onPageChange: (page: number) => void,
  onSubjectClick: (subject: Subject) => void,
  exportCsv: () => void,
  currentPage: ?number,
  rowsPerPage: number,
  count: number,
}

class SubjectsList extends Component<SubjectsListProps> {
  render() {
    const subjects = this.props.items || []

    if (subjects.length == 0) {
      return (
        <EmptyListing image='/images/person.svg'>
          <h5>You have no subjects on this campaign</h5>
          <NavLink to='#' onClick={this.props.showSubjectForm}>Add subject</NavLink>
        </EmptyListing>
      )
    }

    return (
      <div>
        <Button flat primary label='Export CSV' onClick={this.props.exportCsv}>file_download</Button>
        <div className='md-cell md-cell--12'>
          <Card tableCard>
            <DataTable plain className='app-listing' baseId='subjects'>
              <TableHeader>
                <TableRow>
                  <TableColumn>ID</TableColumn>
                  <TableColumn>Phone Number</TableColumn>
                  <TableColumn>Enroll Date</TableColumn>
                  <TableColumn>First Call</TableColumn>
                  <TableColumn>Last Call</TableColumn>
                  <TableColumn>Last Successful Call</TableColumn>
                  <TableColumn>Active?</TableColumn>
                </TableRow>
              </TableHeader>
              <TableBody>
                { subjects.map(s => <SubjectItem key={s.id} subject={s} onClick={this.props.onSubjectClick} />) }
              </TableBody>
              <TablePagination
                rows={this.props.count}
                rowsPerPage={this.props.rowsPerPage}
                rowsPerPageItems={[this.props.rowsPerPage]}
                rowsPerPageLabel=''
                page={this.props.currentPage || 1}
                onPagination={(start, limit) => this.handlePagination(start, limit)}
              />
            </DataTable>
          </Card>
        </div>
      </div>
    )
  }

  handlePagination(start, limit) {
    let page = (start / limit) + 1
    this.props.onPageChange(page)
  }
}

type FormatDateProps = {
  date: ?Date
}
class FormatDate extends Component<FormatDateProps> {
  render() {
    const date = this.props.date

    if (date !== null) {
      return (<Moment format='MMM DD, YYYY HH:mm' date={date} />)
    } else {
      return (<span>-</span>)
    }
  }
}

type SubjectItemProps = {
  subject: Subject,
  onClick: (subject: Subject) => void,
}
class SubjectItem extends Component<SubjectItemProps> {
  render() {
    const subject = this.props.subject
    return (
      <TableRow onClick={() => this.props.onClick(subject)}>
        <TableColumn>{subject.registrationIdentifier}</TableColumn>
        <TableColumn>{subject.phoneNumber}</TableColumn>
        <TableColumn>
          <FormatDate date={subject.enrollDate} />
        </TableColumn>
        <TableColumn>
          <FormatDate date={subject.firstCallDate} />
        </TableColumn>
        <TableColumn>
          <FormatDate date={subject.lastCallDate} />
        </TableColumn>
        <TableColumn>
          <FormatDate date={subject.lastSuccessfulCallDate} />
        </TableColumn>
        <TableColumn>{subject.activeCase ? 'Yes' : 'No'}</TableColumn>
      </TableRow>
    )
  }
}

type SubjectsProps = {
  campaignId: number,
  campaign: {
    fetching: boolean,
    data: Campaign
  },
  subjects: {
    count: number,
    items: Subject[],
    editingSubject: ?SubjectParams,
    limit: number,
    page: ?number,
    targetPage: number,
    fetching: boolean,
  },
  campaignActions: {
    campaignFetch: (campaignId: number) => void
  },
  collectionActions: {
    fetchSubjects: (campaignId: number, limit: number, targetPage: number) => void,
    changeTargetPage: (targetPage: number) => void,
  },
  itemActions: {
    createSubject: (campaignId: number, subject: SubjectParams) => void,
    updateSubject: (campaignId: number, subject: SubjectParams) => void,
    editingSubjectCancel: () => void,
    subjectEditing: (fieldName: string, value: string) => void,
    editSubject: (subject: SubjectParams) => void,
  }
}
class Subjects extends Component<SubjectsProps> {
  closeSubjectFormModal() {
    this.props.itemActions.editingSubjectCancel()
  }

  showSubjectForm() {
    this.props.itemActions.editSubject({phoneNumber: '', registrationIdentifier: ''})
  }

  onEditPhoneNumber = (value) => this.onEditField('phoneNumber', value)
  onEditRegistrationIdentifier = (value) => this.onEditField('registrationIdentifier', value)

  onEditField(fieldName, value) {
    this.props.itemActions.subjectEditing(fieldName, value)
  }

  goToPage(targetPage: number) {
    this.props.collectionActions.changeTargetPage(targetPage)
  }

  fetchTargetPage() {
    const { limit, targetPage } = this.props.subjects
    this.props.collectionActions.fetchSubjects(this.props.campaignId, limit, targetPage)
  }

  exportCsv() {
    window.location.href = `/api/v1/campaigns/${this.props.campaignId}/subjects/export`
  }

  createSubject() {
    if (this.props.subjects.editingSubject != null) {
      this.props.itemActions.createSubject(this.props.campaignId, this.props.subjects.editingSubject)
    } else {
      throw new Error("You can't create without editing a Subject")
    }
  }

  updateSubject() {
    if (this.props.subjects.editingSubject != null) {
      this.props.itemActions.updateSubject(this.props.campaignId, this.props.subjects.editingSubject)
    } else {
      throw new Error("You can't update without editing a Subject")
    }
  }

  editSubject(subject: Subject) {
    this.props.itemActions.editSubject(((subject: any): SubjectParams)) // Subject should work with SubjectParams due compatibility
  }

  pageTitle() {
    return 'Subjects!'
  }

  subjectForm(editingSubject: SubjectParams) {
    return (<SubjectForm
      onSubmit={() => editingSubject.id ? this.updateSubject() : this.createSubject()}
      onCancel={() => this.closeSubjectFormModal()}
      subject={editingSubject}
      onEditPhoneNumber={this.onEditPhoneNumber}
      onEditRegistrationIdentifier={this.onEditRegistrationIdentifier} />)
  }

  circularProgress() {
    return (<CircularProgress id='subjects-fetching-progress' />)
  }

  subjectsList() {
    const {
      page,
      items,
      limit,
      fetching,
      count
    } = this.props.subjects

    return (<SubjectsList
      items={items}
      count={count}
      fetching={fetching}
      currentPage={page}
      rowsPerPage={limit}
      showSubjectForm={() => this.showSubjectForm()}
      exportCsv={() => this.exportCsv()}
      onSubjectClick={(subject) => this.editSubject(subject)}
      onPageChange={(targetPage) => this.goToPage(targetPage)} />)
  }

  componentDidUpdate() {
    const {
      page,
      targetPage,
      fetching
    } = this.props.subjects
    if (page != targetPage && !fetching) {
      this.fetchTargetPage()
    }

    if (!this.props.campaign.data && !this.props.campaign.fetching) {
      this.props.campaignActions.campaignFetch(this.props.campaignId)
    }
  }

  componentDidMount() {
    this.fetchTargetPage()
  }

  render() {
    const {
      editingSubject,
      fetching
    } = this.props.subjects

    const showDialog = editingSubject != null
    let subjectForm = null
    if (editingSubject != null) {
      subjectForm = this.subjectForm(editingSubject)
    }
    let tableOrLoadingIndicator = fetching ? this.circularProgress() : this.subjectsList()

    return (
      <div className='md-grid--no-spacing'>
        <ActiveCampaignSubNav
          title={(this.props.campaign.data && this.props.campaign.data.name) ? this.props.campaign.data.name : ''}
          addButtonHandler={() => this.showSubjectForm()}
          campaignId={this.props.campaignId}
        />
        <div>
          <div className='md-grid'>
            {tableOrLoadingIndicator}
            <Dialog id='subject-form' visible={showDialog} onHide={() => this.closeSubjectFormModal()} title='Manage Subject'>
              {subjectForm}
            </Dialog>
          </div>
        </div>
      </div>
    )
  }
}

const mapStateToProps = (state, ownProps) => ({
  campaignId: parseInt(ownProps.match.params.campaignId),
  campaign: state.campaign,
  subjects: state.subjects
})

const mapDispatchToProps = (dispatch) => ({
  collectionActions: bindActionCreators(collectionActions, dispatch),
  itemActions: bindActionCreators(itemActions, dispatch),
  campaignActions: bindActionCreators(campaignActions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Subjects)
