class FamilyHistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_title
  before_action :set_history, only: [:edit, :update, :destroy]
  before_action :set_view_setting, only: %i(index month year)

  def index
    @histories = current_family.histories.includes(:author, member_histories: :member).newer.page(params[:page]).per(50)
  end

  def month
    @month = (Time.local(params[:year], params[:month]) rescue Time.current).to_date
    @histories = current_family.histories.includes(:author, member_histories: :member).where(target_date: [@month.beginning_of_month..@month.end_of_month]).order(target_date: :asc)
    default_target_date = @month.year == Time.current.year && @month.month == Time.current.month ? Time.current : @month
    @history = current_family.histories.build(target_date: default_target_date)
  end

  def year
    @year = (params[:year] || Time.now.year).to_i
    target_year = Time.local(@year ,1, 1)
    histories = current_family.histories.includes(:author, member_histories: :member).where(target_date: [target_year.beginning_of_year..target_year.end_of_year]).order(target_date: :asc)
    @histories_grouped_by_month = histories.group_by { |h| h.target_date.month }
    @months = 1..12
  end

  # 家族のHistoryを作成する。
  def create
    @history = current_family.histories.build(history_params)
    @history.set_data_by_keys(params[:history], %i[height weight])
    @history.author = current_user
    @history.family = current_family
    assign_member_histories(@history)
    respond_to do |format|
      if @history.save
        format.html do
          redirect_to month_family_family_histories_path(*History.month_path_params(nil, @history.target_date, anchor: true))
        end
        format.json do
          render json: { history: build_history_payload(@history) }
        end
      else
        format.html do
          @month = @history.target_date
          render :month
        end
        format.json do
          render json: { errors: @history.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def edit
  end

  # 家族のHistoryを更新する。
  def update
    @history.set_data_by_keys(params[:history], %i[height weight])
    assign_member_histories(@history)
    unless @history.update(history_params)
      @month = @history.target_date
      render :month
      return
    end
    redirect_to month_family_family_histories_path(*History.month_path_params(nil, @history.target_date, anchor: true))
  end

  def destroy
    target_date = @history.target_date
    @history.destroy
    redirect_to month_family_family_histories_path(*History.month_path_params(nil, target_date)), notice: '削除しました'
  end

  private

  def set_content_title
    title = current_family.present? ? current_family.name : '家族'
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

  # member_keysから中間テーブルを組み立てる。
  def assign_member_histories(history)
    member_keys = Array(params[:member_keys]).map(&:to_s).reject(&:blank?)
    member_histories = member_keys.filter_map do |key|
      type, id = key.split(':', 2)
      next unless %w[User Child].include?(type)
      next if id.blank?
      MemberHistory.new(member_type: type, member_id: id.to_i)
    end
    history.member_histories = member_histories
  end

  # API用のHistory情報を組み立てる。
  def build_history_payload(history)
    {
      id: history.id,
      title: history.title,
      content: history.content,
      target_date: history.target_date&.to_s,
      about_date: history.about_date,
      author_name: history.author&.dispname,
      member_label: history.member_label,
      member_names: history.member_names,
      show_path: history_path(history),
      eyecatch_url: history.eyecatch_image.attached? ? url_for(history.eyecatch_image_large) : nil,
      height: history.height,
      weight: history.weight
    }
  end
end
