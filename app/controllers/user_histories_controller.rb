class UserHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_content_title
  before_action :set_history, only: [:edit, :update, :destroy]
  before_action :set_view_setting, only: %i(index month year)

  def index
    @histories = @user.histories.includes(:author).newer.page(params[:page]).per(50)
  end

  def month
    @month = (Time.local(params[:year], params[:month]) rescue Time.current).to_date
    @histories = @user.histories.includes(:author).where(target_date: [@month.beginning_of_month..@month.end_of_month]).order(target_date: :asc)
    default_target_date = @month.year == Time.current.year && @month.month == Time.current.month ? Time.current : @month
    @history = @user.histories.build(target_date: default_target_date)
  end

  def year
    @year = (params[:year] || Time.now.year).to_i
    target_year = Time.local(@year ,1, 1)
    histories = @user.histories.includes(:author).where(target_date: [target_year.beginning_of_year..target_year.end_of_year]).order(target_date: :asc)
    @histories_grouped_by_month = histories.group_by { |h| h.target_date.month }
    @months = 1..12
  end

  def create
    @history = @user.histories.build(history_params)
    @history.author = current_user
    @history.family = current_family
    unless @history.save
      @month = @history.target_date
      render :month
      return
    end
    redirect_to month_user_user_histories_path(*History.month_path_params(@user, @history.target_date, anchor: true))
  end

  def edit
  end

  def update
    unless @history.update(history_params)
      @month = @history.target_date
      render :month
      return
    end
    redirect_to month_user_user_histories_path(*History.month_path_params(@user, @history.target_date, anchor: true))
  end

  def destroy
    target_date = @history.target_date
    @history.destroy
    redirect_to month_user_user_histories_path(*History.month_path_params(@user, target_date)), notice: '削除しました'
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_content_title
    title = @user.present? ? @user.dispname : 'ユーザーヒストリー'
    @content_title = "#{title}ヒストリー"
  end

  def set_history
    @history = current_family.all_histories.find(params[:id])
  end

  def set_view_setting
    @no_header_margin = true
  end

  def history_params
    params.require(:history).permit(:title, :content, :eyecatch_image, :as_profile_image, :target_date, :about_date)
  end
end
