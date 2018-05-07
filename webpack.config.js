const path = require('path');
const webpack = require('webpack');

module.exports = {
  entry: './public/app.js',
  output: {
    filename: './bundle.js',
    path: path.resolve(__dirname, 'public')
  },
  plugins: [
    new webpack.ProvidePlugin({
        '$': "jquery",
        'jQuery': "jquery",
        'Popper': 'popper.js'
    })
  ]
};
