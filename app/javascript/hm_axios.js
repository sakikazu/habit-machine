import axios from 'axios'

export default axios.create({
  headers: {
    // TODO: 一般的なAPIのセキュリティと思われるAPIキーやJWTへの代替を検討したい。rails依存をなくすくらいのメリット？
    // csrf_meta_tagsヘルパーが出力するcsrf-tokenを読み取る
    'X-CSRF-TOKEN': document.getElementsByName('csrf-token')[0].content,
    // TODO: ここでjsonにしていても、URLパスに.jsonをつけないとjson形式にならない。RailsのRoutesが優先されるってことかな？
    'Content-Type': 'application/json'
  },
  responseType: 'json'
})
