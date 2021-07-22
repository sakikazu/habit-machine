class GeneralController < ApplicationController
  before_action :authenticate_user!

  # 一日分のデータを表示
  def day
    if params[:date].blank?
      @date = Date.today
    else
      begin
        @date = Date.parse(params[:date])
      rescue
        raise NotFound
      end
    end

    @page_title = "#{@date.to_s(:normal)}の記録"
    @no_header_margin = true
  end

  def day_data
    date = Date.parse(params[:date]) rescue nil
    return head :bad_request if date.blank?
    @habits = Habit.with_record_at_date(current_user.habits, date)
    @diaries = current_user.diaries.includes(:tags).where(record_at: date)
    # TODO: DB変更前に、POCでeverydayタグを対象とする
    @everyday_diaries = current_user.diaries.includes(:tags).tagged_with('everyday').order(id: :desc).limit(10)
  end

  def month
    @target_month = if params[:month].present? && params[:month].to_s =~ /^\d{4}-\d{1,2}$/
                      Date.strptime("#{params[:month]}-1")
                    elsif params[:target].present? # from Date Form
                      Date.new(params[:target]["month(1i)"].to_i, params[:target]["month(2i)"].to_i, 1)
                    else
                      Date.today
                    end

    @date_term = @target_month.beginning_of_month..@target_month.end_of_month

    # TODO: グラフ用データ取得は、別クラスにして、パフォーマンス改善する
    basic_habits = current_user.habits.status_enabled

    habit_results_for_oresen = build_graph_data(basic_habits.result_type_line_graph)
    @habits_for_oresen_graph = build_graph(habit_results_for_oresen)

    habit_results_for_bou = build_graph_data(basic_habits.result_type_bar_graph)
    @habits_for_bou_graph = build_bou_graph(habit_results_for_bou)

    @habits = Habit.with_records_in_date_term(current_user.habits.status_enabled, @date_term)
    @diaries = Diary.group_by_record_at(current_user, @date_term)

    @page_title = "#{@target_month.strftime('%Y年%m月')}の記録"
  end


  private

  # 指定のHabitにひもづくRecordから、指定の期間分取得してグラフ用にデータ整形
  def build_graph_data(habits)
    habit_results = []

    records_its_type = Record.where(habit_id: habits.map{|h| h.id}).where("value IS NOT NULL").where(record_at: @date_term).order(:record_at)
    records_group_by_habit = records_its_type.group_by{|r| r.habit_id}
    habits.each do |habit|
      # group_by{|r| r.record_at.to_s} だとグループ化されたデータは配列になってしまうので使用側で注意が必要になる。のでわざわざループで設定する
      records = {}
      records_group_by_habit[habit.id].each do |r|
        records[r.record_at.to_s] = r
      end if records_group_by_habit[habit.id].present?
      habit_results << {id: habit.id, title: habit.title,
                        value_unit: habit.value_unit,
                        records: records}
    end
    habit_results
  end

  def build_graph(results_for_oresen)
    xAxis_categories = @date_term.map{|date| date.to_s(:short)}
    tickInterval     = 0

    return LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '折れ線グラフタイプの結果')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)

      results_for_oresen.each do |result|
        # recordをグラフX軸にすべて埋める
        graph_data = []
        prev_data = 0
        @date_term.each do |date|
          found_record = result[:records][date.to_s]
          # 折れ線グラフの月の初日のデータが記録されていなかった場合、当月以前の最後のデータを取得してそれを使う
          if date == date.beginning_of_month and found_record.blank?
            last_record = Record.where(habit_id: result[:id]).where("value IS NOT NULL").where("record_at < ?", date.beginning_of_month).order("record_at DESC").first
            val_beginning_of_month = last_record.blank? ? 0 : last_record.value
            graph_data << val_beginning_of_month
            prev_data = val_beginning_of_month
          elsif found_record.present?
            graph_data << found_record.value
            prev_data = found_record.value
          else
            graph_data << prev_data
          end
        end
        f.series(name: "#{result[:title]}(#{result[:value_unit]})", data: graph_data, type: Habit::GRAPH_TYPE_ORESEN)
      end

      # 複数にする場合
      # f.options[:yAxis] = [{ title: { text: 'y軸1のタイトル' }}, { title: { text: 'y軸2のタイトル'}, opposite: true}]
      # f.series(name: '棒グラフの名前',     data: data1, type: 'column', yAxis: 1)
      # f.series(name: '折れ線グラフの名前', data: data2, type: 'spline')
    end
  end

  def build_bou_graph(results_for_bou)
    xAxis_categories = @date_term.map{|date| date.to_s(:short)}
    tickInterval     = 0

    return LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: '棒グラフタイプの結果')
      f.xAxis(categories: xAxis_categories, tickInterval: tickInterval)
      # デフォルトだと画面サイズになってしまい、棒グラフの棒が細くなりすぎるのを防ぐため
      f.chart(width: 3000)

      results_for_bou.each do |result|
        graph_data = []
        max_value = 0
        @date_term.each do |date|
          found_record = result[:records][date.to_s]
          if found_record.present?
            graph_data << found_record.value
            max_value = found_record.value if max_value < found_record.value
          else
            graph_data << 0
          end
        end
        # ジョギング(km)のデータも小さい値に表示したいので、MAXが30と考えていいかな
        yaxis_type = max_value > 30 ? 0 : 1
        f.series(name: "#{result[:title]}(#{result[:value_unit]})", yAxis: yaxis_type, data: graph_data, type: Habit::GRAPH_TYPE_BOU)
      end
      f.yAxis [
        {title: {text: "値が大きいやつ", margin: 20} },
        {title: {text: "値が小さいやつ"}, margin: 20, opposite: true},
      ]
    end
  end
end
