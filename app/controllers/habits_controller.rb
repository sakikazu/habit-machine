# -*- coding: utf-8 -*-
class HabitsController < ApplicationController
  before_filter :authenticate_user!

  #
  # 記録結果
  #
  def result
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

    basic_habits = Habit.where(user_id: current_user.id).enable

    # 結果をテーブル表示するHabit
    habits_for_table = basic_habits.where(result_type: 1)

    @habits_for_table = []
    records_for_table_tmp = Record.where(habit_id: habits_for_table.map{|h| h.id}).where("value IS NOT NULL").where(record_at: @date_term)
    records_for_table = records_for_table_tmp.group_by{|r| r.habit_id}
    habits_for_table.each do |habit|
      @habits_for_table << {id: habit.id, title: habit.title, value_unit: habit.value_unit, records: records_for_table[habit.id]}
    end


    # 結果を折れ線グラフで表示するHabit

    # @habittitle_for_graph = @habits.map{|h| h.title}
    # records = Record.where(habit_id: @habits.map{|h| h.id}).where("value IS NOT NULL").order("record_at ASC")
    # # todo mapの使い方 viewの方ではto_jsonでJSにオブジェクトを渡したり
    # grouped_records = records.group_by{|r| r.record_at}
    # @records_for_graph = grouped_records.map do |key, records|
      # tmp = {record_at: key}
      # records.each do |rec|
        # tmp[rec.habit.title] = rec.value
      # end
      # tmp
    # end

# p @habittitle_for_graph
    # p @records_for_graph
  end

  #
  # 目標一覧
  #
  def goal
    @enable_habits = Habit.where(user_id: current_user.id).enable
    @disable_habits = Habit.where(user_id: current_user.id).disable
    @close_habits = Habit.where(user_id: current_user.id).close
  end


  # GET /habits
  # GET /habits.json
  def index

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

    # 対象期間分の習慣データを取得／作成(インライン編集のためにRecordは予め作成しておく)
    habits = Habit.where(user_id: current_user.id).enable
    @habits = []
    habits.each do |habit|
      records = []
      # todo ここはマトリックス分のselectが発生するので、まずは一気にselectして、そこでないもののみcreateするようにしたい
      # doto これ使うかな→ @records = @habits.includes(:records).where("records.record_at" => @date_term).group(:habit_id)

      @date_term.each do |date|
        records << Record.find_or_create(habit.id, date)
      end
      @habits << {id: habit.id, title: habit.title, value_unit: habit.value_unit, records: records}
    end

    # 対象期間分の日記データを取得
    @diaries = Diary.where(user_id: current_user.id, record_at: @date_term).order("id ASC")
    @diaries = @diaries.group_by{|d| d.record_at}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @habits }
    end
  end

  # GET /habits/1
  # GET /habits/1.json
  def show
    @habit = Habit.find(params[:id])

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
    @habit = Habit.find(params[:id])
  end

  # POST /habits
  # POST /habits.json
  def create
    params[:habit][:user_id] = current_user.id
    @habit = Habit.new(params[:habit])

    respond_to do |format|
      if @habit.save
        format.html { redirect_to habits_path, notice: '習慣データを作成しました.' }
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
    @habit = Habit.find(params[:id])

    respond_to do |format|
      if @habit.update_attributes(params[:habit])
        format.html { redirect_to habits_path, notice: '習慣データを更新しました.' }
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
    @habit = Habit.find(params[:id])
    @habit.destroy

    respond_to do |format|
      format.html { redirect_to habits_url }
      format.json { head :no_content }
    end
  end
end
