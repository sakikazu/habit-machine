class ChildHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child
  before_action :set_content_title
  before_action :set_history, only: [:edit, :update, :destroy]
  before_action :set_view_setting, only: %i(month year)

  def month
    @month = (Time.local(params[:year], params[:month]) rescue Time.current).to_date
    @histories = @child.histories.includes(:author).where(target_date: [@month.beginning_of_month..@month.end_of_month]).order(target_date: :asc)
    default_target_date = @month.year == Time.current.year && @month.month == Time.current.month ? Time.current : @month
    @history = @child.histories.build(target_date: default_target_date)
  end

  def year
    @year = (params[:year] || Time.now.year).to_i
    target_year = Time.local(@year ,1, 1)
    histories = @child.histories.includes(:author).where(target_date: [target_year.beginning_of_year..target_year.end_of_year]).order(target_date: :asc)
    @histories_grouped_by_month = histories.group_by { |h| h.target_date.month }
    @months = 1..12
  end

  def create
    @history = @child.histories.build(history_params)
    @history.set_data_by_keys(params[:history], %i[height weight])
    @history.author = current_user
    @history.family = current_family
    unless @history.save
      @month = @history.target_date
      render :month
      return
    end
    redirect_to month_child_child_histories_path(*History.month_path_params(@child, @history.target_date, anchor: true))
  end

  def edit
  end

  def update
    @history.set_data_by_keys(params[:history], %i[height weight])
    unless @history.update(history_params)
      @month = @history.target_date
      @child = @history.source
      render :month
      return
    end
    redirect_to month_child_child_histories_path(*History.month_path_params(@history.source, @history.target_date, anchor: true))
  end

  def destroy
    target_date = @history.target_date
    child = @history.source
    @history.destroy
    redirect_to month_child_child_histories_path(*History.month_path_params(@history.source, target_date)), notice: '削除しました'
  end

  private

  def set_child
    @child = current_family.children.find(params[:child_id])
  end

  def set_content_title
    @content_title = @child.present? ? @child.name : 'こども'
  end

  # TODO: 認可ライブラリで置き換える
  def set_history
    @history = History.find(params[:id])
    head :not_found unless current_family.children.include?(@history.source)
  end

  def set_view_setting
    @no_header_margin = true
  end

  def history_params
    params.require(:history).permit(:title, :content, :image, :as_profile_image, :target_date, :about_date)
  end
end
