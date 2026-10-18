const assert = require('assert')
const {
  headingPathAtEnd,
  lineIndexAt,
  matchHabitTemplateEntries,
  parseHabitTemplate,
  replacementFor,
  replacementForChoice,
} = require('../../app/javascript/habit_template_examples.js')

function test (description, callback) {
  callback()
  process.stdout.write(`✓ ${description}\n`)
}

test('入力例をハイフンへ変換し、入力例がない部分は維持する', () => {
  const parsed = parseHabitTemplate('### 睡眠\n- 睡眠：[[7時間]]\n自由入力')
  assert.strictEqual(parsed.text, '### 睡眠\n- 睡眠：-\n自由入力')
  assert.strictEqual(parsed.entries[0].example, '7時間')
})

test('入力例がないテンプレートは従来どおり返す', () => {
  const template = '### メモ\n自由入力'
  assert.deepStrictEqual(parseHabitTemplate(template), { text: template, entries: [] })
})

test('同名項目を見出しで区別する', () => {
  const parsed = parseHabitTemplate('### 朝\n- 眠気：[[0〜4]]\n\n### 昼\n- 眠気：[[なし/あり]]')
  const matches = matchHabitTemplateEntries(parsed.text, parsed.entries)
  assert.strictEqual(matches[1].entry.example, '0〜4')
  assert.strictEqual(matches[4].entry.example, 'なし/あり')
})

test('挿入位置の親見出しを継承して対応付ける', () => {
  const existing = '# 健康\n## 今日'
  const parsed = parseHabitTemplate('### 睡眠\n- 時間：[[7時間]]', headingPathAtEnd(existing))
  const text = `${existing}\n${parsed.text}`
  const matches = matchHabitTemplateEntries(text, parsed.entries)
  assert.strictEqual(matches[3].entry.example, '7時間')
})

test('同じ見出し内の同名項目を出現順で区別する', () => {
  const parsed = parseHabitTemplate('### 体調\n- 眠気：[[朝]]\n- 眠気：[[昼]]')
  const matches = matchHabitTemplateEntries(parsed.text, parsed.entries)
  assert.strictEqual(matches[1].entry.example, '朝')
  assert.strictEqual(matches[2].entry.example, '昼')
})

test('項目名や見出しが編集された場合は対応付けない', () => {
  const parsed = parseHabitTemplate('### 体調\n- 眠気：[[0〜4]]')
  assert.deepStrictEqual(matchHabitTemplateEntries('### 体調\n- 疲労：-', parsed.entries), {})
  assert.deepStrictEqual(matchHabitTemplateEntries('### 生活\n- 眠気：-', parsed.entries), {})
})

test('候補行が増えて曖昧になった場合は対応付けない', () => {
  const parsed = parseHabitTemplate('### 体調\n- 眠気：[[0〜4]]')
  const text = '### 体調\n- 眠気：-\n- 眠気：-'
  assert.deepStrictEqual(matchHabitTemplateEntries(text, parsed.entries), {})
})

test('未入力記号だけを置換対象にする', () => {
  const parsed = parseHabitTemplate('### 体調\n- 眠気：[[0〜4]]')
  const matches = matchHabitTemplateEntries(parsed.text, parsed.entries)
  assert.deepStrictEqual(replacementFor(parsed.text, 1, matches[1]), {
    start: 12,
    end: 13,
    replacement: '0〜4',
  })

  const entered = '### 体調\n- 眠気：3'
  const enteredMatch = matchHabitTemplateEntries(entered, parsed.entries)[1]
  assert.strictEqual(replacementFor(entered, 1, enteredMatch), null)
})

test('カーソル位置から行番号を取得する', () => {
  assert.strictEqual(lineIndexAt('一行目\n二行目', 5), 1)
})

test('選択式入力例を解析し、先頭候補を置換値にする', () => {
  const parsed = parseHabitTemplate('- 寝起き：[[選択:1悪い/2普通 / 3良い]]')
  const entry = parsed.entries[0]
  const match = matchHabitTemplateEntries(parsed.text, parsed.entries)[0]

  assert.deepStrictEqual(entry.choices, ['1悪い', '2普通', '3良い'])
  assert.strictEqual(replacementFor(parsed.text, 0, match).replacement, '1悪い')
})

test('候補ボタンは未入力または定義済み候補だけを置換する', () => {
  const parsed = parseHabitTemplate('- 寝起き：[[選択:1悪い/2普通/3良い]]')
  const emptyMatch = matchHabitTemplateEntries(parsed.text, parsed.entries)[0]
  assert.deepStrictEqual(replacementForChoice(parsed.text, 0, emptyMatch, '2普通'), {
    start: 6,
    end: 7,
    replacement: '2普通',
  })

  const selected = '- 寝起き：1悪い'
  const selectedMatch = matchHabitTemplateEntries(selected, parsed.entries)[0]
  assert.deepStrictEqual(replacementForChoice(selected, 0, selectedMatch, '3良い'), {
    start: 6,
    end: 9,
    replacement: '3良い',
  })

  const entered = '- 寝起き：自由入力'
  const enteredMatch = matchHabitTemplateEntries(entered, parsed.entries)[0]
  assert.strictEqual(replacementForChoice(entered, 0, enteredMatch, '1悪い'), null)
})
