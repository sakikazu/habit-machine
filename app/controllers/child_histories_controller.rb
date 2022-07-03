class ChildHistoriesController < ApplicationController
  before_action :set_child, only: [:month, :year]
  before_action :set_child_history, only: [:edit, :update, :destroy]

  def month
    @month = (Time.local(params[:year], params[:month]) rescue Time.current).to_date
    @histories = @child.child_histories.includes(:author).where(target_date: [@month.beginning_of_month..@month.end_of_month]).order(target_date: :asc)
    default_target_date = @month.year == Time.current.year && @month.month == Time.current.month ? Time.current : @month
    @history = @child.child_histories.build(target_date: default_target_date)

    @no_header_margin = true
  end

  def year
    @year = (params[:year] || Time.now.year).to_i
    target_year = Time.local(@year ,1, 1)
    histories = @child.child_histories.includes(:author).where(target_date: [target_year.beginning_of_year..target_year.end_of_year]).order(target_date: :asc)
    @histories_grouped_by_month = histories.group_by { |h| h.target_date.month }
    @months = 1..12

    @no_header_margin = true
  end

  def create
    @child = Child.find(params[:child_id])
    @history = @child.child_histories.build(child_history_params)
    set_data_if_need
    @history.author = current_user
    unless @history.save
      @month = @history.target_date
      render 'children/show'
      return
    end
    redirect_to month_histories_child_path(@child, @history.target_date.year, @history.target_date.month, anchor: "history-#{@history.target_date.strftime('%Y-%m-%d')}")
  end

  def edit
    if @history.data.present?
      history_data = @history.data.with_indifferent_access
      @history.height = history_data[:height]
      @history.weight = history_data[:weight]
    end
  end

  def update
    set_data_if_need
    unless @history.update(child_history_params)
      @month = @history.target_date
      render 'children/show'
      return
    end
    redirect_to month_histories_child_path(@history.child, @history.target_date.year, @history.target_date.month, anchor: "history-#{@history.target_date.strftime('%Y-%m-%d')}")
  end

  def destroy
    target_date = @history.target_date
    child = @history.child
    @history.destroy
    redirect_to month_histories_child_path(@history.child, target_date.year, target_date.month), notice: '削除しました'
  end

  private

  def set_child
    # NOTE: routes的に `id` でchild_idが渡される
    @child = Child.find(params[:id])
  end

  def set_child_history
    @history = ChildHistory.find(params[:id])
  end

  def child_history_params
    params.require(:child_history).permit(:title, :content, :image, :as_profile_image, :target_date, :about_date)
  end

  def set_data_if_need
    if params[:child_history][:height].present? || params[:child_history][:weight].present?
      @history.data = {
        height: params[:child_history][:height],
        weight: params[:child_history][:weight]
      }
    end
  end
end
