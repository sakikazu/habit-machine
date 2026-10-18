const EXAMPLE_PATTERN = /\[\[([^\]\r\n]+)\]\]/g
const HEADING_PATTERN = /^\s{0,3}(#{1,6})\s+(.+?)\s*#*\s*$/

// 見出し階層を含む項目識別子を生成する
function itemKey (headingPath, linePrefix, lineSuffix) {
  return `${headingPath.join('\u001f')}\u001e${linePrefix}\u001e${lineSuffix}`
}

// Markdownの現在行までの見出し階層を更新する
function updateHeadingPath (headingPath, row) {
  const heading = row.match(HEADING_PATTERN)
  if (!heading) return headingPath

  const level = heading[1].length
  const nextPath = headingPath.slice(0, level - 1)
  nextPath[level - 1] = heading[2].trim()
  return nextPath
}

// 本文末尾で有効なMarkdown見出し階層を取得する
function headingPathAtEnd (text) {
  let headingPath = []
  ;(text || '').split(/\r?\n/).forEach((row) => {
    headingPath = updateHeadingPath(headingPath, row)
  })
  return headingPath
}

// テンプレートを挿入用本文と入力例の対応情報へ分解する
function parseHabitTemplate (template, initialHeadingPath = []) {
  const source = template || ''
  const entries = []
  const occurrenceCounts = {}
  let headingPath = initialHeadingPath.slice()

  const text = source.split(/\r?\n/).map((row) => {
    headingPath = updateHeadingPath(headingPath, row)
    const matches = Array.from(row.matchAll(EXAMPLE_PATTERN))
    const convertedRow = row.replace(EXAMPLE_PATTERN, '-')

    // 一行に複数の入力例がある場合は変換だけ行い、安全のため入力補助の対象外にする
    if (matches.length !== 1 || !/^\s*[-*+]\s+/.test(row)) return convertedRow

    const match = matches[0]
    const choiceMatch = match[1].match(/^選択:(.+)$/)
    const choices = choiceMatch ? choiceMatch[1].split('/').map(choice => choice.trim()).filter(Boolean) : []
    const linePrefix = row.slice(0, match.index)
    const lineSuffix = row.slice(match.index + match[0].length)
    const key = itemKey(headingPath, linePrefix, lineSuffix)
    const occurrence = occurrenceCounts[key] || 0
    occurrenceCounts[key] = occurrence + 1

    entries.push({
      id: `${key}\u001d${occurrence}`,
      key,
      headingPath: headingPath.slice(),
      heading: headingPath[headingPath.length - 1] || '',
      label: linePrefix.replace(/^\s*[-*+]\s+/, '').replace(/[：:]\s*$/, '').trim(),
      example: choiceMatch ? choiceMatch[1] : match[1],
      choices: choices.length > 1 ? choices : [],
      linePrefix,
      lineSuffix,
      occurrence,
    })

    return convertedRow
  }).join('\n')

  return { text, entries }
}

// 本文の行と入力例を照合し、曖昧さがない場合だけ対応を返す
function matchHabitTemplateEntries (text, entries) {
  const rows = (text || '').split(/\r?\n/)
  const candidates = {}
  const expectedCounts = {}
  const matchesByLine = {}
  let headingPath = []

  entries.forEach((entry) => {
    expectedCounts[entry.key] = (expectedCounts[entry.key] || 0) + 1
  })

  rows.forEach((row, lineIndex) => {
    headingPath = updateHeadingPath(headingPath, row)
    entries.forEach((entry) => {
      if (headingPath.join('\u001f') !== entry.headingPath.join('\u001f')) return
      if (!row.startsWith(entry.linePrefix) || !row.endsWith(entry.lineSuffix)) return

      const valueEnd = row.length - entry.lineSuffix.length
      if (valueEnd < entry.linePrefix.length) return
      if (!candidates[entry.key]) candidates[entry.key] = []
      if (!candidates[entry.key].some(candidate => candidate.lineIndex === lineIndex)) {
        candidates[entry.key].push({ lineIndex, value: row.slice(entry.linePrefix.length, valueEnd) })
      }
    })
  })

  entries.forEach((entry) => {
    const keyCandidates = candidates[entry.key] || []
    if (keyCandidates.length !== expectedCounts[entry.key]) return
    const candidate = keyCandidates[entry.occurrence]
    if (candidate) matchesByLine[candidate.lineIndex] = { entry, value: candidate.value }
  })

  return matchesByLine
}

// selectionStartからカーソルがある行番号を取得する
function lineIndexAt (text, selectionStart) {
  return (text || '').slice(0, selectionStart).split(/\r?\n/).length - 1
}

// 未入力記号だけを置換するための選択範囲を返す
function replacementFor (text, lineIndex, match) {
  if (!match || match.value !== '-') return null

  const rows = (text || '').split(/\r?\n/)
  if (!rows[lineIndex]) return null
  const rowStart = rows.slice(0, lineIndex).reduce((length, row) => length + row.length + 1, 0)
  const start = rowStart + match.entry.linePrefix.length
  const replacement = match.entry.choices.length > 0 ? match.entry.choices[0] : match.entry.example
  return { start, end: start + 1, replacement }
}

// 未入力または定義済み候補の値だけを指定候補へ置換する
function replacementForChoice (text, lineIndex, match, choice) {
  if (!match || !match.entry.choices.includes(choice)) return null
  if (match.value !== '-' && !match.entry.choices.includes(match.value)) return null

  const rows = (text || '').split(/\r?\n/)
  if (!rows[lineIndex]) return null
  const rowStart = rows.slice(0, lineIndex).reduce((length, row) => length + row.length + 1, 0)
  const start = rowStart + match.entry.linePrefix.length
  return { start, end: start + match.value.length, replacement: choice }
}

module.exports = {
  headingPathAtEnd,
  lineIndexAt,
  matchHabitTemplateEntries,
  parseHabitTemplate,
  replacementFor,
  replacementForChoice,
}
