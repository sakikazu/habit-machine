class HabitsController < ApplicationController
  before_action :set_habit, only: [:show, :edit, :update, :destroy]
  before_action :set_content_title, only: [:show, :edit]
  before_action :authenticate_user!

  # GET /habits
  # GET /habits.json
  def index
    @enable_habits = Habit.available_by_user(current_user).status_enabled
    @disable_habits = Habit.available_by_user(current_user).status_disabled
    @close_habits = Habit.available_by_user(current_user).status_done
  end

  # GET /habits/1
  # GET /habits/1.json
  def show
    @records = @habit.records.has_data.newer.page(params[:page]).per(200)
    if params[:habit].present? && params[:habit][:search_word].present?
      searcher = HabitRecordSearcher.new(@records, params[:habit][:search_word])
      @records = searcher.result
      @habit.search_word = params[:habit][:search_word]
    end

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
    @habit = Habit.new(habit_params)
    @habit.source = params[:for_family].to_i == 1 ? current_family : current_user

    respond_to do |format|
      if @habit.save
        format.html { redirect_to habit_path(@habit), notice: '習慣データを作成しました.' }
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
        format.html { redirect_to habit_path(@habit), notice: '習慣データを更新しました.' }
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
    @habit = Habit.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def habit_params
    params.require(:habit).permit(:value_type, :value_unit, :result_type, :reminder, :title, :goal, :status, :memo, :template)
  end
end
