// Markdown入力欄のリスト・表入力を標準Textarea APIで補助する
(function(global) {
  const attachedListeners = new WeakMap()

  const position = (target) => ({ start: target.selectionStart, end: target.selectionEnd })
  const select = (target, start, end = start) => {
    target.focus()
    target.setSelectionRange(start, end)
  }
  const replaceSelection = (target, text) => {
    const { start, end } = position(target)
    target.setRangeText(text, start, end, 'end')
  }
  const notifyInput = (target) => target.dispatchEvent(new Event('input', { bubbles: true }))

  const currentLine = (event) => {
    const target = event.target
    const text = target.value
    const pos = position(target)
    if (!text || pos.start !== pos.end) return null
    const start = text.lastIndexOf('\n', pos.start - 1) + 1
    let end = text.indexOf('\n', pos.start)
    if (end === -1) end = text.length
    return {
      text: text.slice(start, end),
      start,
      end,
      caret: pos.start,
      endOfLine: !text.slice(pos.start, end).trim(),
    }
  }

  const previousLine = (event) => {
    const line = currentLine(event)
    const text = event.target.value.slice(0, line.start)
    const start = text.lastIndexOf('\n', line.start - 2) + 1
    return { text: text.slice(start, line.start), start, end: line.start }
  }

  const handleTab = (event) => {
    const line = currentLine(event)
    if (!line || !line.text.match(/^ *- /)) return
    event.preventDefault()
    const target = event.target
    const originalPosition = position(target)
    select(target, line.start, line.end)
    const selectedText = target.value.slice(target.selectionStart, target.selectionEnd)

    if (event.shiftKey) {
      const replacement = selectedText.replace(/^ {1,4}/gm, '')
      const removedCount = selectedText.length - replacement.length
      replaceSelection(target, replacement)
      select(target, originalPosition.start - removedCount)
    } else {
      replaceSelection(target, `    ${selectedText.split('\n').join('\n    ')}`)
      select(target, originalPosition.start + 4)
    }
    notifyInput(target)
  }

  const handleEnter = (event) => {
    if (event.metaKey || event.ctrlKey || event.shiftKey) return
    const line = currentLine(event)
    if (!line || line.start === line.caret) return
    const target = event.target
    let match

    if ((match = line.text.match(/^(\s*(?:-|\+|\*|\d+\.) (?:\[(?:x| )\] )?)\s*\S/))) {
      if (line.text.match(/^(\s*(?:-|\+|\*|\d+\.) (?:\[(?:x| )\] ))\s*$/)) {
        select(target, line.start, line.end - 1)
        return
      }
      event.preventDefault()
      let listMark = match[1].replace(/\[x\]/, '[ ]')
      const numbered = listMark.match(/^(\s*)(\d+)\./)
      if (numbered && parseInt(numbered[2], 10) !== 1) {
        listMark = listMark.replace(/\s*\d+/, `${numbered[1]}${parseInt(numbered[2], 10) + 1}`)
      }
      replaceSelection(target, `\n${listMark}`)
      select(target, line.caret + listMark.length + 1)
    } else if (line.text.match(/^(\s*(?:-|\+|\*|\d+\.) )/)) {
      select(target, line.start, line.end)
    } else if (line.text.match(/^.*\|\s*$/)) {
      if (line.text.match(/^[\|\s]+$/)) {
        select(target, line.start, line.end)
        return
      }
      if (!line.endOfLine) return
      event.preventDefault()
      const row = line.text.match(/\|/g).map(() => '|')
      const previous = previousLine(event)
      if (!previous || (!line.text.match(/---/) && !previous.text.match(/\|/g))) {
        replaceSelection(target, `\n${row.join(' --- ')}\n${row.join('  ')}`)
        select(target, line.caret + 6 * row.length - 1)
      } else {
        replaceSelection(target, `\n${row.join('  ')}`)
        select(target, line.caret + 3)
      }
    }
    notifyInput(target)
  }

  global.markdownEasily = function(target) {
    if (!target) return
    const previousListener = attachedListeners.get(target)
    if (previousListener) target.removeEventListener('keydown', previousListener)
    const listener = (event) => {
      if (event.key === 'Tab') handleTab(event)
      if (event.key === 'Enter') handleEnter(event)
    }
    attachedListeners.set(target, listener)
    target.addEventListener('keydown', listener)
  }
})(typeof window === 'undefined' ? globalThis : window)
