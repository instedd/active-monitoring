import React, {Component} from 'react'

export default class EmptyListing extends Component {
  render() {
    return (
      <div className="app-listing-no-data md-text-center">
        <div className="app-listing-no-data-image">
          <object type="image/svg+xml" data={this.props.image} width="100%"></object>
        </div>
        <div className="app-listing-no-data-text">
          {this.props.children}
        </div>
      </div>
    )
  }
}
