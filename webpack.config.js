const path = require('path')
const fs = require('fs')
const { VueLoaderPlugin } = require('vue-loader')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')

const isProduction = process.env.NODE_ENV === 'production'
const entrypointsDir = path.resolve(__dirname, 'app/javascript/entrypoints')

const entries = {}
if (fs.existsSync(entrypointsDir)) {
  fs.readdirSync(entrypointsDir).forEach((file) => {
    if (!/\.(js|jsx|mjs|ts|tsx)$/.test(file)) return
    const name = path.basename(file, path.extname(file))
    entries[name] = path.join(entrypointsDir, file)
  })
}

if (Object.keys(entries).length === 0) {
  throw new Error('No entrypoints found in app/javascript/entrypoints')
}

const styleLoader = isProduction
  ? MiniCssExtractPlugin.loader
  : 'style-loader'

module.exports = {
  mode: isProduction ? 'production' : 'development',
  entry: entries,
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'app/assets/builds'),
    publicPath: '/assets/'
  },
  devtool: isProduction ? 'source-map' : 'eval-source-map',
  module: {
    rules: [
      {
        test: /\.(js|jsx|mjs|ts|tsx)(\.erb)?$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.vue$/,
        loader: 'vue-loader'
      },
      {
        test: /\.pug$/,
        loader: 'pug-plain-loader'
      },
      {
        test: /\.sass$/i,
        use: [
          styleLoader,
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
      },
      {
        test: /\.scss$/i,
        use: [styleLoader, 'css-loader', 'sass-loader']
      },
      {
        test: /\.css$/i,
        use: [styleLoader, 'css-loader']
      },
      {
        test: [
          /\.bmp$/,
          /\.gif$/,
          /\.jpe?g$/,
          /\.png$/,
          /\.tiff$/,
          /\.ico$/,
          /\.avif$/,
          /\.webp$/,
          /\.eot$/,
          /\.otf$/,
          /\.ttf$/,
          /\.woff$/,
          /\.woff2$/,
          /\.svg$/
        ],
        type: 'asset/resource',
        generator: {
          filename: 'static/[name]-[hash][ext][query]'
        }
      }
    ]
  },
  resolve: {
    extensions: ['.vue', '.js', '.jsx', '.mjs', '.ts', '.tsx'],
    alias: {
      vue$: 'vue/dist/vue.esm.js'
    },
    modules: [path.resolve(__dirname, 'app/javascript'), 'node_modules']
  },
  plugins: [
    new VueLoaderPlugin(),
    ...(isProduction ? [new MiniCssExtractPlugin()] : [])
  ]
}
