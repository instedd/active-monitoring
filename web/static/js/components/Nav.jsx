import React from 'react'
import { Link } from 'react-router-dom'


export default (() =>
  <header className="mui-appbar mui--z1">
    <div className="mui-container">
      <table width="100%">
        <tbody><tr className="mui--appbar-height">
          <td style={{textAlign:'left'}}>
            <ul className="mui-list--inline mui--text-body2">
              <li><Link to='campaigns'>Campaigns</Link></li>
              <li><Link to='channels'>Channels</Link></li>
            </ul>
          </td>
        </tr>
        </tbody></table>
    </div>
  </header>
)
