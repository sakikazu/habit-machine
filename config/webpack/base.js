const { webpackConfig, merge } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const pug = require('./loaders/pug')
const fullBuildConfig = require('./fullBuild')

const withIndentedSass = (config) => {
  if (!config.module || !Array.isArray(config.module.rules)) {
    return config
  }

  const sassRuleIndex = config.module.rules.findIndex((rule) =>
    rule.test && rule.test.toString().includes('scss|sass')
  )
  if (sassRuleIndex < 0) {
    return config
  }

  const sassRule = config.module.rules[sassRuleIndex]
  const use = Array.isArray(sassRule.use) ? sassRule.use : []
  const indentedUse = use.map((entry) => {
    if (!entry || typeof entry !== 'object') {
      return entry
    }
    if (!entry.loader || !entry.loader.includes('sass-loader')) {
      return entry
    }
    const options = entry.options ? { ...entry.options } : {}
    const sassOptions = options.sassOptions ? { ...options.sassOptions } : {}
    return {
      ...entry,
      options: {
        ...options,
        sassOptions: {
          ...sassOptions,
          indentedSyntax: true
        }
      }
    }
  })

  const indentedRule = {
    ...sassRule,
    test: /\.sass(\.erb)?$/i,
    use: indentedUse
  }

  sassRule.test = /\.(scss)(\.erb)?$/i
  config.module.rules.splice(sassRuleIndex, 0, indentedRule)

  return config
}

const baseConfig = withIndentedSass(merge(webpackConfig, fullBuildConfig))

const customConfig = {
  resolve: {
    extensions: ['.vue', '.js', '.jsx', '.mjs', '.ts', '.tsx', '.coffee']
  },
  module: {
    rules: [vue, pug]
  },
  plugins: [new VueLoaderPlugin()]
}

module.exports = merge(customConfig, baseConfig)
