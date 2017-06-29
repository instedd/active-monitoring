import React, { Component } from 'react'
import Toolbar from 'react-md/lib/Toolbars'
import MenuButton from 'react-md/lib/Menus/MenuButton'
import Button from 'react-md/lib/Buttons/Button'
import ListItem from 'react-md/lib/Lists/ListItem'
import PropTypes from 'prop-types'
import SubNav from './SubNav'
import { NavLink } from 'react-router-dom'
import { logout } from '../api'

const UserInfo = ({displayName}) =>
  <MenuButton
    id='user-menu'
    buttonChildren="arrow_drop_down"
    className='app-user-menu'
    label={displayName}
    position={MenuButton.Positions.BELOW}
    flat
    >
    <ListItem primaryText='Preferences' />
    <ListItem onClick={logout} primaryText='Sign out' />
  </MenuButton>

UserInfo.propTypes = {
  displayName: PropTypes.string
}

const UserNav = ({displayName}) => <nav>
              <div className='sections'>
                <Button href='/campaigns' flat label="Campaigns" />
                <Button href='/channels' flat label="Channels" />
              </div>
              <UserInfo displayName={displayName} />
            </nav>

UserNav.propTypes = {
  displayName: PropTypes.string
}

export default ({data}) =>
  <Toolbar
    className='mainToolbar'
    colored
    nav={<UserNav displayName="User Name"/>}
  />
