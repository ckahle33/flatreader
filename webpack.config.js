const path = require('path');
const webpack = require('webpack');
const CompressionPlugin = require("compression-webpack-plugin")
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

module.exports = {
  entry: {
    app: ['./public/app.js', './public/main.sass']
  },
  output: {
    filename: './public/bundle.js',
    path: path.resolve(__dirname, "public")
  },
  module: {
    rules: [
      {
        test: /\.(sass|css)$/,
        use: [
          MiniCssExtractPlugin.loader,
          {
            loader: 'css-loader'
          },
          {
            loader: 'sass-loader',
            options: {
              sourceMap: true,
              // options...
            }
          }
        ]
      },
      {
        test: /\.m?js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: 'public/main.css'
    }),
  ]
};
