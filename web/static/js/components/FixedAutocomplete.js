import Autocomplete from 'react-md/lib/Autocompletes'

export default class FixedAutocomplete extends Autocomplete {
  fixedHandleClick(e) {
    let target = e.target
    while (target && target.parentNode) {
      if (target.classList.contains('md-list-item') && target.parentNode.classList.contains('md-autocomplete-list')) {
        let items = target.parentNode.querySelectorAll('.md-list-item')
        items = Array.prototype.slice.call(items)

        return this._handleItemClick(items.indexOf(target))
      }

      target = target.parentNode
    }

    return null
  }

  constructor(props) {
    super(props)
    this._handleClick = this.fixedHandleClick.bind(this)
  }
}

FixedAutocomplete.propTypes = Autocomplete.propTypes
FixedAutocomplete.defaultProps = Autocomplete.defaultProps
