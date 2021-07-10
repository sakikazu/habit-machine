// Vue.jsで完全ビルドを有効にする
// vueとturbolinksを共存させる https://qiita.com/rhistoba/items/a06f60a509e87604164e
// これまで各jsファイル内で指定していた `vue/dist/vue.esm.js` のaliasを作っただけぽいので、必要ないかも
module.exports = {
  resolve: {
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }
  }
}
