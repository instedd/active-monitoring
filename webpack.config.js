var ExtractTextPlugin = require("extract-text-webpack-plugin");
var CopyWebpackPlugin = require("copy-webpack-plugin");

module.exports = {
  resolve: {
    /* Load path for required files */
    modules: [ __dirname + "/node_modules",
               __dirname + "/web/static/js"
             ]
  },

  /*
   Entry points.
   Only code referenced from this files will be included in the target bundles.
   */
  entry: [
    "./web/static/js/app.js",
    "./web/static/css/app.scss"
  ],

  output: {
    path: __dirname + "/priv/static",
    filename: "js/app.js"
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['es2015']
          }
        }
      },
      {
        test: /\.css$/,
        use: ExtractTextPlugin.extract({use: 'css-loader'})
      },
      {
        test: /\.scss$/,
        use: ExtractTextPlugin.extract({use: [{loader: "css-loader"}, {loader: "sass-loader"}]})
      }
    ]
  },

  /* Include sourcemaps along generated files */
  devtool: "cheap-module-source-map",

  plugins: [
    /* Extract all compiled styles into a separate stylesheet instead of
    requiring CSS from javascript files as Webpack does by default. */
    new ExtractTextPlugin("css/app.css"),

    /* Copy static assets from web/static/assets.
     Note that when new messages are added we still need to restart the webpack
     watch.
     */
    new CopyWebpackPlugin([{ from: "./web/static/assets" }])
  ]
};
