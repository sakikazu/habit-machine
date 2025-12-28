class HistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_history, only: %i[show edit update destroy]

  # Historyの詳細を表示する。
  def show
  end

  # Historyの編集フォームを表示する。
  def edit
  end

  # Historyを作成する。
  def create
    @history = current_family.histories.build(history_params)
    @history.set_data_by_keys(params[:history], %i[height weight])
    @history.author = current_user
    @history.family = current_family
    assign_member_histories(@history)

    if @history.save
      redirect_to history_path(@history)
    else
      render :edit
    end
  end

  # Historyを更新する。
  def update
    @history.set_data_by_keys(params[:history], %i[height weight])
    assign_member_histories(@history)

    if @history.update(history_params)
      redirect_to history_path(@history)
    else
      render :edit
    end
  end

  # Historyを削除する。
  def destroy
    @history.destroy
    redirect_to family_path, notice: '削除しました'
  end

  private

  def set_history
    @history = current_family.histories.find(params[:id])
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
end
