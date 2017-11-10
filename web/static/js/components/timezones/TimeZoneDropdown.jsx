import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { fetchTimezones } from '../../actions/timezones'
import { formatTimezone } from './util'
import SelectField from 'react-md/lib/SelectFields'
import { connect } from 'react-redux'

class TimezoneDropdown extends Component {
  componentDidMount() {
    const { dispatch } = this.props
    dispatch(fetchTimezones())
  }

  render() {
    const { timezones, selected, onEdit, readOnly } = this.props

    if (!timezones || !timezones.items) {
      return (
        <div>Loading timezones...</div>
      )
    }

    const timezonesWithFormat = timezones.items.map((timezone) => ({value: timezone, label: formatTimezone(timezone)}))

    return (
      <SelectField
        id='timezone'
        menuItems={timezonesWithFormat}
        className='md-cell md-cell--8  md-cell--bottom'
        value={selected}
        onChange={onEdit}
        readOnly={readOnly}
      />
    )
  }
}

TimezoneDropdown.propTypes = {
  dispatch: PropTypes.func.isRequired,
  timezones: PropTypes.object,
  selected: PropTypes.string,
  onEdit: PropTypes.func,
  readOnly: PropTypes.bool
}

const mapStateToProps = (state) => ({
  timezones: state.timezones
})

export default connect(mapStateToProps)(TimezoneDropdown)
