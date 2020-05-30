import axios from 'axios'

export default axios.create({
  headers: {
    'X-CSRF-TOKEN': document.getElementsByName('csrf-token')[0].content,
    // TODO: ここでjsonにしていても、URLパスに.jsonをつけないとjson形式にならない。RailsのRoutesが優先されるってことかな？
    'Content-Type': 'application/json'
  },
  responseType: 'json'
})
