class HabitsController < ApplicationController
  before_action :set_habit, only: [:show, :edit, :update, :destroy]
  before_action :set_content_title, only: [:show, :edit]
  before_action :authenticate_user!

  #
  # 記録結果
  #
  def result
    @action_name = "記録の結果"

    @showable = params[:showable]

    # 対象月
    if params[:target].present? # from Date Form
      target_month = Date.new(
        params[:target]["month(1i)"].to_i,
        params[:target]["month(2i)"].to_i,
        params[:target]["month(3i)"].to_i
      )
      @target_month = target_month
    else
      @target_month = Date.today
    end
    @date_term = @target_month.beginning_of_month..@target_month.end_of_month

    basic_habits = Habit.by_user(current_user).enable

    @habits_all= build_graph_data(basic_habits.all)

    habit_results_for_oresen = build_graph_data(basic_habits.where(result_type: Habit::RESULT_TYPE_ORESEN))
    @habits_for_oresen_graph = build_graph(habit_results_for_oresen)

    habit_results_for_bou = build_graph_data(basic_habits.where(result_type: Habit::RESULT_TYPE_BOU))
    @habits_for_bou_graph = build_bou_graph(habit_results_for_bou)

    @diaries = Diary.group_by_record_at(current_user, @date_term)
  end


  # GET /habits
  # GET /habits.json
  def index
    @enable_habits = Habit.by_user(current_user).enable
    @disable_habits = Habit.by_user(current_user).disable
    @close_habits = Habit.by_user(current_user).close
  end

  #
  # top
  #
  def top
    @action_name = "トップページ"

    # 起点（ページの中心日）の前後＊日分のデータが対象
    if params[:one_day].present?
      @one_day = Date.strptime(params[:one_day])
    elsif params[:record_at].present? # from Date Form
      select_day = Date.new(
        params[:record_at]["one_day(1i)"].to_i,
        params[:record_at]["one_day(2i)"].to_i,
        params[:record_at]["one_day(3i)"].to_i
      )
      @one_day = select_day
    else
      @one_day = Date.today
    end
    @date_term = (@one_day - 3)..(@one_day + 3)

    # 対象期間分の習慣データを取得
    @habits = []
    habits = Habit.by_user(current_user).enable
    records = Record.where(habit_id: habits.map{|h| h.id}, record_at: @date_term).order(:record_at)
    records_grouped_by_habit = records.group_by{|r| r.habit_id}

    habits.each do |habit|
      records = []
      records_by_habit = records_grouped_by_habit[habit.id]
      @date_term.each do |date|
        found_record = records_by_habit.blank? ? nil : records_by_habit.detect{|r| r.record_at == date}
        records << (found_record.present? ? found_record : Record.new(habit_id: habit.id, record_at: date))
      end

      @habits << {id: habit.id, title: habit.title, value_unit: habit.value_unit, value_type: habit.value_type, records: records}
    end

    # memo これはシンプルだが、Recordが日付範囲にない場合、LEFT OUTER JOINでもhabitsさえ取得できなくなる。これができるSQLってあるのか？
    # @habits = Habit.by_user(current_user).enable.includes(:records).where("records.record_at" => @date_term)
    # @habits.each do |habit|
      # records_included_new_instance = []
      # @date_term.each do |date|
        # found_record = habit.records.detect{|r| r.record_at == date}
        # records_included_new_instance << (found_record.present? ? found_record : Record.new(habit_id: habit.id, record_at: date))
      # end
      # habit.records_included_new_instance = records_included_new_instance
    # end


    @diaries = Diary.group_by_record_at(current_user, @date_term)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @habits }
    end
  end

  # GET /habits/1
  # GET /habits/1.json
  def show
    @records = @habit.records.where("value is not NULL").order("record_at DESC").page(params[:page]).per(200)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @habit }
    end
  end

  # GET /habits/new
  # GET /habits/new.json
  def new
    @habit = Habit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @habit }
    end
  end

  # GET /habits/1/edit
  def edit
  end

  # POST /habits
  # POST /habits.json
  def create
    params[:habit][:user_id] = current_user.id
    @habit = Habit.new(habit_params)

    respond_to do |format|
      if @habit.save
        format.html { redirect_to root_path, notice: '習慣データを作成しました.' }
        format.json { render json: @habit, status: :created, location: @habit }
      else
        format.html { render action: "new" }
        format.json { render json: @habit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /habits/1
  # PUT /habits/1.json
  def update
    respond_to do |format|
      if @habit.update_attributes(habit_params)
        format.html { redirect_to root_path, notice: '習慣データを更新しました.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @habit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /habits/1
  # DELETE /habits/1.json
  def destroy
    @habit.destroy

    respond_to do |format|
      format.html { redirect_to habits_url, notice: '習慣データを削除しました.' }
      format.json { head :no_content }
    end
  end

  private
  def set_content_title
    @content_title = @habit.present? ? @habit.title : ""
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_habit
    @habit = Habit.by_user(current_user).find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def habit_params
    params.require(:habit).permit(:value_type, :value_unit, :result_type, :reminder, :title, :user_id, :goal, :status, :memo)
  end


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
