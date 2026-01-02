class ChildHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child
  before_action :set_content_title
  before_action :set_view_setting, only: %i(year)

  def year
    @year = (params[:year] || Time.now.year).to_i
    set_year_histories(@year)
  end

  private

  def set_child
    @child = current_family.children.find(params[:child_id])
  end

  def set_content_title
    @content_title = @child.present? ? @child.name : 'こども'
  end

  def set_view_setting
    @no_header_margin = true
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
