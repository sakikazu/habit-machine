class ChildHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child
  before_action :set_content_title
  before_action :set_history, only: [:edit, :update, :destroy]
  before_action :set_view_setting, only: %i(year)

  def year
    @year = (params[:year] || Time.now.year).to_i
    set_year_histories(@year)
  end

  def create
    @history = History.new(history_params)
    @history.member_histories.build(member: @child)
    @history.set_data_by_keys(params[:history], %i[height weight])
    @history.author = current_user
    @history.family = current_family
    unless @history.save
      set_year_histories(@history.target_date.year)
      render :year
      return
    end
    redirect_to year_child_child_histories_path(@child, @history.target_date.year)
  end

  def edit
  end

  def update
    @history.set_data_by_keys(params[:history], %i[height weight])
    unless @history.update(history_params)
      set_year_histories(@history.target_date.year)
      render :year
      return
    end
    redirect_to year_child_child_histories_path(@child, @history.target_date.year)
  end

  def destroy
    target_date = @history.target_date
    @history.destroy
    redirect_to year_child_child_histories_path(@child, target_date.year), notice: '削除しました'
  end

  private

  def set_child
    @child = current_family.children.find(params[:child_id])
  end

  def set_content_title
    @content_title = @child.present? ? @child.name : 'こども'
  end

  # TODO: 現状でも問題ないが、認可ライブラリも導入したいところ
  def set_history
    @history = current_family.histories.find(params[:id])
  end

  def set_view_setting
    @no_header_margin = true
  end

  def history_params
    params.require(:history).permit(:title, :content, :eyecatch_image, :as_profile_image, :target_date, :about_date)
  end

  # 年ページの一覧表示に必要なデータをまとめる
  def set_year_histories(year)
    @year = year
    target_year = Time.local(@year, 1, 1)
    histories = @child.histories.includes(:author).where(target_date: [target_year.beginning_of_year..target_year.end_of_year]).order(target_date: :asc)
    @histories_grouped_by_month = histories.group_by { |history| history.target_date.month }
    @months = 1..12
  end
end
