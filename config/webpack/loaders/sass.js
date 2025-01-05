module.exports = {
  test: /\.sass$/,
  use: [
    'vue-style-loader',
    'css-loader',
    {
      loader: 'sass-loader',
      options: {
        sassOptions: {
          indentedSyntax: true
        }
      }
    }
  ]
}
