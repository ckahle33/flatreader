const path = require('path');
const webpack = require('webpack');
const CompressionPlugin = require("compression-webpack-plugin")

module.exports = {
  entry: './public/app.js',
  output: {
    filename: './bundle.js',
    path: path.resolve(__dirname, 'public')
  },
  plugins: [
    new CompressionPlugin(),
    new webpack.ProvidePlugin({
        '$': "jquery",
        'jQuery': "jquery",
        'Popper': 'popper.js'
    })
  ]
};
