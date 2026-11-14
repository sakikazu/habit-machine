const assert = require('assert')

global.Event = class {
  constructor(type, options = {}) {
    this.type = type
    this.bubbles = options.bubbles
  }
}

require('../../app/assets/javascripts/markdown-easily.js')

class Textarea {
  constructor(value, caret = value.length) {
    this.value = value
    this.selectionStart = caret
    this.selectionEnd = caret
    this.listeners = {}
  }

  addEventListener(type, listener) { this.listeners[type] = listener }
  removeEventListener(type) { delete this.listeners[type] }
  dispatchEvent() {}
  focus() {}
  setSelectionRange(start, end) {
    this.selectionStart = start
    this.selectionEnd = end
  }
  setRangeText(text, start, end) {
    this.value = this.value.slice(0, start) + text + this.value.slice(end)
    this.selectionStart = this.selectionEnd = start + text.length
  }
  keydown(options) {
    this.listeners.keydown({
      target: this,
      key: options.key,
      shiftKey: !!options.shiftKey,
      metaKey: false,
      ctrlKey: false,
      preventDefault() {},
    })
  }
}

const list = new Textarea('- item')
global.markdownEasily(list)
list.keydown({ key: 'Enter' })
assert.strictEqual(list.value, '- item\n- ')

const nestedList = new Textarea('- item')
global.markdownEasily(nestedList)
nestedList.keydown({ key: 'Tab' })
assert.strictEqual(nestedList.value, '    - item')
nestedList.keydown({ key: 'Tab', shiftKey: true })
assert.strictEqual(nestedList.value, '- item')

console.log('✓ Markdownリストの継続・インデント・解除をjQueryなしで処理する')
