# -*- coding: utf-8 -*-
class HabitsController < ApplicationController
  before_filter :authenticate_user!

  #
  # 目標一覧
  #
  def goal
    @habits = Habit.where(user_id: current_user.id)
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
    habits = Habit.where(user_id: current_user.id)
    @habits = []
    habits.each do |habit|
      records = []
      # todo ここはマトリックス分のselectが発生するので、まずは一気にselectして、そこでないもののみcreateするようにしたい
      # doto これ使うかな→ @records = @habits.includes(:records).where("records.record_at" => @date_term).group(:habit_id)

      @date_term.each do |date|
        records << Record.find_or_create(habit.id, date)
      end
      @habits << {id: habit.id, title: habit.title, data_unit: habit.data_unit, records: records}
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
