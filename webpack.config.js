var path = require('path')
var ExtractTextPlugin = require('extract-text-webpack-plugin')
var CopyWebpackPlugin = require('copy-webpack-plugin')
var FlowBabelWebpackPlugin = require('flow-babel-webpack-plugin')

module.exports = {
  devServer: {
    disableHostCheck: true,
    host: '0.0.0.0',
    port: 4001,
    overlay: true
  },

  resolve: {

    /* Load path for required files */
    modules: [
      path.join(__dirname, 'node_modules'),
      path.join(__dirname, '_web/static/js')
    ],

    extensions: ['.js', '.jsx']
  },

  /*
   Entry points.
   Only code referenced from this files will be included in the target bundles.
   */
  entry: [
    './web/static/js/app.jsx',
    './web/static/css/app.scss'
  ],

  output: {
    path: path.join(__dirname, 'priv/static'),
    filename: 'js/app.js'
  },

  module: {
    rules: [
      {
        test: /\.(js|jsx)$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015', 'stage-0', 'react'],
            plugins: ['transform-object-rest-spread', 'transform-flow-comments']
          }
        }
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({use: 'css-loader'})
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({use: [{loader: 'css-loader'}, {loader: 'sass-loader'}]})
      }
    ]
  },

  /* Include sourcemaps along generated files */
  devtool: 'cheap-module-source-map',

  plugins: [
    /* Extract all compiled styles into a separate stylesheet instead of
       requiring CSS from javascript files as Webpack does by default. */
    new ExtractTextPlugin('css/app.css'),

    /* Copy static assets from web/static/assets.
       Note that when new messages are added we still need to restart the webpack
       watch.
     */
    new CopyWebpackPlugin([{ from: './web/static/assets' }]),

    new FlowBabelWebpackPlugin()
  ]
}
