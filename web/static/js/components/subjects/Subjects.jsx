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

import * as collectionActions from '../../actions/subjects'
import * as itemActions from '../../actions/subject'
import EmptyListing from '../EmptyListing'
import SubjectForm from './SubjectForm'
import SubNav from '../SubNav'
import type { Subject, SubjectParams } from '../../types'

class SubjectsList extends Component {
  props: {
    items: Subject[],
    showSubjectForm: () => void,
    onPageChange: (page: number) => void,
    onSubjectClick: (subject: Subject) => void,
    currentPage: ?number,
    rowsPerPage: number,
    count: number,
  }

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
      <div className='md-grid'>
        <div className='md-cell md-cell--12'>
          <Card tableCard>
            <DataTable plain className='app-listing' baseId='subjects'>
              <TableHeader>
                <TableRow>
                  <TableColumn>ID</TableColumn>
                  <TableColumn>Phone Number</TableColumn>
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

class SubjectItem extends Component {
  props: {
    subject: Subject,
    onClick: (subject: Subject) => void,
  }

  render() {
    const subject = this.props.subject
    return (
      <TableRow onClick={() => this.props.onClick(subject)}>
        <TableColumn>{subject.registrationIdentifier}</TableColumn>
        <TableColumn>{subject.phoneNumber}</TableColumn>
      </TableRow>
    )
  }
}

class Subjects extends Component {
  props: {
    campaignId: number,
    subjects: {
      count: number,
      items: Subject[],
      editingSubject: ?SubjectParams,
      limit: number,
      page: ?number,
      targetPage: number,
      fetching: boolean,
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

  componentDidUpdate() {
    const {
      page,
      targetPage,
      fetching
    } = this.props.subjects
    if (page != targetPage && !fetching) {
      this.fetchTargetPage()
    }
  }

  componentDidMount() {
    this.fetchTargetPage()
  }

  render() {
    const {
      editingSubject,
      page,
      items,
      limit,
      fetching,
      count
    } = this.props.subjects

    const showDialog = editingSubject != null
    let subjectForm = null
    if (editingSubject != null) {
      subjectForm = <SubjectForm
        onSubmit={() => editingSubject.id ? this.updateSubject() : this.createSubject()}
        onCancel={() => this.closeSubjectFormModal()}
        subject={editingSubject}
        onEditPhoneNumber={this.onEditPhoneNumber}
        onEditRegistrationIdentifier={this.onEditRegistrationIdentifier} />
    }
    let tableOrLoadingIndicator = fetching ? <CircularProgress id='subjects-fetching-progress' /> : (<SubjectsList
      items={items}
      count={count}
      fetching={fetching}
      currentPage={page}
      rowsPerPage={limit}
      showSubjectForm={() => this.showSubjectForm()}
      onSubjectClick={(subject) => this.editSubject(subject)}
      onPageChange={(targetPage) => this.goToPage(targetPage)} />)

    return (
      <div className='md-grid--no-spacing'>
        <SubNav addButtonHandler={() => this.showSubjectForm()}>
          Subjects
        </SubNav>
        {tableOrLoadingIndicator}
        <Dialog id='subject-form' visible={showDialog} onHide={() => this.closeSubjectFormModal()} title='Manage Subject'>
          {subjectForm}
        </Dialog>
      </div>
    )
  }
}

const mapStateToProps = (state, ownProps) => ({
  campaignId: parseInt(ownProps.match.params.campaignId),
  subjects: state.subjects
})

const mapDispatchToProps = (dispatch) => ({
  collectionActions: bindActionCreators(collectionActions, dispatch),
  itemActions: bindActionCreators(itemActions, dispatch)
})

export default connect(mapStateToProps, mapDispatchToProps)(Subjects)
