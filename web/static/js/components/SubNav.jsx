// @flow
import React, {Component} from 'react'
import { push } from 'react-router-redux'
import { connect } from 'react-redux'
import { Tabs, Tab } from 'react-md'
import AddButton from './AddButton'

const IconActive = () =>
  <img src='/images/icon.svg' width='60' height='60' className='logo' />

type Props = {
  addButtonHandler: Function,
  children: any,
  navigate: Function,
  map: Function,
  tabsList: Function
}
class SubNav extends Component<Props> {
  goToItem(itemIndex) {
    this.props.navigate(this.props.tabsList[itemIndex].url)
  }

  render() {
    let addButton = null
    let tabs = null
    if (this.props.addButtonHandler) {
      addButton = <AddButton onClick={this.props.addButtonHandler} />
    }

    if (this.props.tabsList) {
      let tabIndex = this.props.tabsList.findIndex((element) => (element.url == window.location.pathname))
      tabs = (
        <div className='tabs-container'>
          <Tabs tabId='tabsList' id='Tabs' onTabChange={(tabIndex) => this.goToItem(tabIndex)} activeTabIndex={tabIndex}>
            {
              this.props.tabsList.map((item) => (
                <Tab key={item.label}
                  label={item.label}
                />)
              )
            }
          </Tabs>
        </div>
      )
    }

    return (
      <nav className='sub-nav'>
        <IconActive />
        <h1>{this.props.children}</h1>
        { tabs }
        { addButton }
      </nav>
    )
  }
}

const mapDispatchToProps = (dispatch) => ({
  navigate: (path) => dispatch(push(path))
})

export default connect(null, mapDispatchToProps)(SubNav)
