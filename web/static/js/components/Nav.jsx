import React from 'react'
import Toolbar from 'react-md/lib/Toolbars'
import MenuButton from 'react-md/lib/Menus/MenuButton'
import Button from 'react-md/lib/Buttons/Button'
import ListItem from 'react-md/lib/Lists/ListItem'
import PropTypes from 'prop-types'
import { logout } from '../api'
import { config } from '../config'

const UserInfo = ({displayName}) =>
  <MenuButton
    id='user-menu'
    buttonChildren='arrow_drop_down'
    className='app-user-menu'
    iconBefore={false}
    label={displayName}
    position={MenuButton.Positions.BELOW}
    flat
    >
    <ListItem primaryText='Preferences' />
    <ListItem onClick={() => logout(config.logout_url)} primaryText='Sign out' />
  </MenuButton>

UserInfo.propTypes = {
  displayName: PropTypes.string
}

const UserNav = ({displayName}) => <nav>
  <div className='sections'>
    <Button href='/campaigns' flat label='Campaigns' />
  </div>
  <UserInfo displayName={displayName} />
</nav>

UserNav.propTypes = {
  displayName: PropTypes.string
}

export default () =>
  <Toolbar
    className='mainToolbar'
    colored
    nav={<UserNav displayName={config.user} />}
  />
