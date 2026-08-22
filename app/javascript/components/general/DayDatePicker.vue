<template lang="pug">
.day-date-picker(ref="root")
  button.date-selector(type="button" @click.stop="toggleCalendar" :aria-expanded="calendarOpen.toString()" aria-controls="inline-calendar") {{ displayDate }}
  #inline-calendar.inline-calendar(v-if="calendarOpen" @click.stop)
    .calendar-header
      button.calendar-month-button(type="button" @click="changeCalendarPeriod(-1)" :aria-label="calendarPreviousLabel") ‹
      button.calendar-title-button(type="button" @click="toggleCalendarYearSelection" :aria-expanded="calendarYearSelectionOpen.toString()") {{ calendarTitle }}
      button.calendar-month-button(type="button" @click="changeCalendarPeriod(1)" :aria-label="calendarNextLabel") ›
    .calendar-years(v-if="calendarYearSelectionOpen")
      button.calendar-year(
        v-for="year in calendarYears"
        :key="year"
        type="button"
        @click="selectCalendarYear(year)"
        :class="{ 'is-selected': year === calendarYear }"
        :aria-current="year === calendarYear ? 'date' : null"
      ) {{ year }}年
    .calendar-weekdays(v-if="!calendarYearSelectionOpen" aria-hidden="true")
      span(v-for="weekday in calendarWeekdays" :key="weekday") {{ weekday }}
    .calendar-days(v-if="!calendarYearSelectionOpen")
      span.calendar-day-placeholder(v-for="blank in calendarLeadingBlankCount" :key="`blank-${blank}`")
      a.calendar-day(
        v-for="day in calendarDays"
        :key="day"
        :href="dayPath(day)"
        :class="{ 'is-selected': isSelectedCalendarDay(day), 'is-today': isTodayCalendarDay(day) }"
        :aria-current="isSelectedCalendarDay(day) ? 'date' : null"
        :aria-label="calendarDayAriaLabel(day)"
      ) {{ day }}
</template>

<script>
export default {
  name: 'DayDatePicker',
  props: {
    selectedDate: {
      type: String,
      required: true,
    },
    displayDate: {
      type: String,
      required: true,
    },
    dayPathTemplate: {
      type: String,
      required: true,
    },
  },
  data () {
    const [year, month] = this.selectedDate.split('-').map(Number)
    return {
      calendarOpen: false,
      calendarYear: year,
      calendarMonth: month,
      calendarYearSelectionOpen: false,
      calendarWeekdays: ['日', '月', '火', '水', '木', '金', '土'],
    }
  },
  computed: {
    // 表示月の日数をDate標準の繰り上がりで求める
    calendarDays () {
      const lastDay = new Date(this.calendarYear, this.calendarMonth, 0).getDate()
      return Array.from({ length: lastDay }, (_, index) => index + 1)
    },
    // 月初より前に表示する空セル数を求める
    calendarLeadingBlankCount () {
      return new Date(this.calendarYear, this.calendarMonth - 1, 1).getDay()
    },
    // 年選択では12年、日付選択では現在の年月を見出しに表示する
    calendarTitle () {
      if (this.calendarYearSelectionOpen) {
        return `${this.calendarYears[0]}年〜${this.calendarYears[this.calendarYears.length - 1]}年`
      }
      return `${this.calendarYear}年 ${this.calendarMonth}月`
    },
    // 選択中の年を含む12年単位の一覧を返す
    calendarYears () {
      const firstYear = Math.floor(this.calendarYear / 12) * 12
      return Array.from({ length: 12 }, (_, index) => firstYear + index)
    },
    // 左移動ボタンの表示モードに応じたラベルを返す
    calendarPreviousLabel () {
      return this.calendarYearSelectionOpen ? '前の12年' : '前の月'
    },
    // 右移動ボタンの表示モードに応じたラベルを返す
    calendarNextLabel () {
      return this.calendarYearSelectionOpen ? '次の12年' : '次の月'
    },
  },
  mounted () {
    document.addEventListener('click', this.closeCalendarOnOutsideClick)
  },
  beforeDestroy () {
    document.removeEventListener('click', this.closeCalendarOnOutsideClick)
  },
  methods: {
    // インラインカレンダーの開閉を切り替える
    toggleCalendar () {
      this.calendarOpen = !this.calendarOpen
      if (!this.calendarOpen) this.calendarYearSelectionOpen = false
    },
    // カレンダー外の操作でカレンダーを閉じる
    closeCalendarOnOutsideClick (event) {
      if (this.calendarOpen && !this.$refs.root.contains(event.target)) {
        this.calendarOpen = false
        this.calendarYearSelectionOpen = false
      }
    },
    // ページ遷移せず表示月だけを切り替える
    changeCalendarMonth (amount) {
      const nextMonth = new Date(this.calendarYear, this.calendarMonth - 1 + amount, 1)
      this.calendarYear = nextMonth.getFullYear()
      this.calendarMonth = nextMonth.getMonth() + 1
    },
    // 表示中の選択モードに応じて月または12年を切り替える
    changeCalendarPeriod (amount) {
      if (this.calendarYearSelectionOpen) {
        this.calendarYear += amount * 12
        return
      }
      this.changeCalendarMonth(amount)
    },
    // 年月見出しから年選択と日付選択を切り替える
    toggleCalendarYearSelection () {
      this.calendarYearSelectionOpen = !this.calendarYearSelectionOpen
    },
    // 選んだ年を反映して日付選択へ戻る
    selectCalendarYear (year) {
      this.calendarYear = year
      this.calendarYearSelectionOpen = false
    },
    // Railsのroute helperで生成したテンプレートへ選択日を埋め込む
    dayPath (day) {
      const date = `${this.calendarYear}-${String(this.calendarMonth).padStart(2, '0')}-${String(day).padStart(2, '0')}`
      return this.dayPathTemplate.replace('__DATE__', date)
    },
    // 日付セルが現在表示中の日付か判定する
    isSelectedCalendarDay (day) {
      const [year, month, selectedDay] = this.selectedDate.split('-').map(Number)
      return this.calendarYear === year && this.calendarMonth === month && day === selectedDay
    },
    // 日付セルが今日か判定する
    isTodayCalendarDay (day) {
      const today = new Date()
      return this.calendarYear === today.getFullYear() && this.calendarMonth === today.getMonth() + 1 && day === today.getDate()
    },
    // スクリーンリーダー向けの日付ラベルを返す
    calendarDayAriaLabel (day) {
      return `${this.calendarYear}年${this.calendarMonth}月${day}日`
    },
  },
}
</script>

<style scoped lang="sass">
.day-date-picker
  width: 100%
  position: relative

.date-selector
  height: 50px
  width: 100%
  background: white
  border: 2px solid #2563eb
  border-radius: 8px
  display: flex
  align-items: center
  justify-content: center
  position: relative
  padding: 0 24px
  font-size: 20px
  font-weight: bold
  color: #374151
  cursor: pointer
  transition: background-color 0.2s

  &:hover
    background: #ebf5ff

  &::after
    content: ""
    position: absolute
    right: 12px
    width: 8px
    height: 8px
    border-left: 2px solid #2563eb
    border-bottom: 2px solid #2563eb
    transform: rotate(-45deg) translateY(-2px)

  &[aria-expanded="true"]::after
    transform: rotate(135deg) translate(-2px, -2px)

.inline-calendar
  position: absolute
  z-index: 30
  top: 56px
  left: 50%
  width: calc(100vw - 24px)
  max-width: 426px
  transform: translateX(-50%)
  box-sizing: border-box
  padding: 10px
  background: #f8fbff
  border: 2px solid #2563eb
  border-radius: 8px
  box-shadow: 0 6px 16px rgba(37, 99, 235, 0.16)

.calendar-header
  min-height: 40px
  display: flex
  align-items: center
  justify-content: space-between
  color: #374151

.calendar-month-button
  width: 40px
  height: 40px
  padding: 0
  border: 0
  border-radius: 6px
  background: transparent
  color: #2563eb
  font-size: 28px
  line-height: 1
  cursor: pointer

  &:hover
    background: #dbeafe

.calendar-title-button
  min-height: 40px
  padding: 0 14px
  border: 0
  border-radius: 6px
  background: transparent
  color: #374151
  font-weight: bold
  cursor: pointer

  &:hover
    background: #dbeafe

.calendar-years
  display: grid
  grid-template-columns: repeat(3, minmax(0, 1fr))
  gap: 4px

.calendar-year
  min-height: 44px
  border: 1px solid transparent
  border-radius: 6px
  background: transparent
  color: #374151
  cursor: pointer

  &:hover
    background: #dbeafe

  &.is-selected
    background: #2563eb
    border-color: #2563eb
    color: white
    font-weight: bold

.calendar-weekdays,
.calendar-days
  display: grid
  grid-template-columns: repeat(7, minmax(0, 1fr))

.calendar-weekdays span
  display: flex
  min-height: 32px
  align-items: center
  justify-content: center
  color: #6b7280
  font-size: 13px

.calendar-day,
.calendar-day-placeholder
  min-width: 0
  min-height: 40px

.calendar-day
  display: flex
  align-items: center
  justify-content: center
  margin: 1px
  border: 1px solid transparent
  border-radius: 6px
  color: #374151
  text-decoration: none

  &:hover
    background: #dbeafe
    color: #1d4ed8
    text-decoration: none

  &.is-today
    border-color: #60a5fa

  &.is-selected
    background: #2563eb
    border-color: #2563eb
    color: white
    font-weight: bold
</style>
