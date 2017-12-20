import { connect } from 'react-redux'
import React, { Component } from 'react'
import PropTypes from 'prop-types'
import iso6393 from 'iso-639-3'
import { addEmptyLang, editLang, removeLang } from '../../actions/langs'
import { campaignUpdate } from '../../actions/campaign'
import { codeToName } from '../../langs'
import Button from 'react-md/lib/Buttons/Button'
import List from 'react-md/lib/Lists/List'
import ListItemControl from 'react-md/lib/Lists/ListItemControl'
import FontIcon from 'react-md/lib/FontIcons'
import FixedAutocomplete from '../FixedAutocomplete'

class LanguageStepComponent extends Component {
  render() {
    const languages = iso6393.map(obj => ({label: obj.name, value: obj.iso6391}))
                             .filter(obj => obj.value != null && !this.props.langs.includes(obj.value))

    return (
      <section id='languages' className='full-height'>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            <h1>Select languages</h1>
            <p>
              Select all the languages the caller can choose between. Each will have their own set of audios.
            </p>
          </div>
        </div>
        <div className='md-grid'>
          <List className='md-cell md-cell--12 add-language'>
            {(this.props.langs || []).map((id, i) =>
              // List item control is necessary for the autocomplete to work, and it requires primaryText
              // Issue on this is pending: https://github.com/mlaursen/react-md/issues/412
              <ListItemControl
                key={id}
                primaryText=''
                rightIcon={<FontIcon className='cursor' onClick={() => this.props.onRemove(i)}>cancel</FontIcon>}
                primaryAction={
                  <FixedAutocomplete
                    id={`autocomplete${i}`}
                    data={languages}
                    filter={FixedAutocomplete.caseInsensitiveFilter}
                    onAutocomplete={(lbl, j, obj) => this.props.onEdit(obj[j].value, i)}
                    block={false}
                    dataLabel='label'
                    dataValue='value'
                    defaultValue={codeToName(id) || ''}
                  />}
              />)}
          </List>
          <Button flat label='Add another language' className='btn-add-grey' onClick={this.props.onAdd}>add</Button>
        </div>
        <div className='md-grid'>
          <div className='md-cell md-cell--12'>
            {this.props.children}
          </div>
        </div>
      </section>
    )
  }
}

LanguageStepComponent.propTypes = {
  onRemove: PropTypes.func,
  onEdit: PropTypes.func,
  onAdd: PropTypes.func,
  langs: PropTypes.arrayOf(PropTypes.string),
  children: PropTypes.element
}

const mapStateToProps = (state) => {
  return {
    langs: state.campaign.data.langs
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    onAdd: () => dispatch(addEmptyLang()),
    onEdit: (lang, index) => dispatch(editLang(lang, index)),
    onRemove: (index) => dispatch(removeLang(index)),
    onEditForwarding: (key, value) => dispatch(campaignUpdate({[key]: value}))
  }
}

const LanguageStep = connect(
  mapStateToProps,
  mapDispatchToProps
)(LanguageStepComponent)

export default LanguageStep
