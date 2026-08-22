class HistoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_history, only: %i[show edit update destroy]

  # Historyの詳細を表示する。
  def show
    respond_to do |format|
      format.html
      format.json { render json: { history: build_history_detail_payload(@history) } }
    end
  end

  # Historyの編集フォームを表示する。
  def edit
    respond_to do |format|
      format.html
      format.json do
        render json: { form_html: render_to_string(partial: 'histories/form', locals: { history: @history }, formats: [:html]) }
      end
    end
  end

  # Historyを作成する。
  def create
    @history = current_family.histories.build(history_params)
    @history.set_data_by_keys(params[:history], %i[height weight])
    @history.author = current_user
    @history.family = current_family
    assign_member_histories(@history)

    respond_to do |format|
      if @history.save
        format.html { redirect_to history_path(@history) }
        format.json { render json: { history: build_history_payload(@history) } }
      else
        format.html { render :edit }
        format.json { render json: { errors: @history.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Historyを更新する。
  def update
    @history.set_data_by_keys(params[:history], %i[height weight])
    assign_member_histories(@history)

    respond_to do |format|
      if @history.update(history_params)
        format.html { redirect_to history_path(@history) }
        format.json { render json: { history: build_history_payload(@history) } }
      else
        format.html { render :edit }
        format.json { render json: { errors: @history.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Historyを削除する。
  def destroy
    deleted_id = @history.id
    @history.destroy
    respond_to do |format|
      format.html { redirect_to family_path, notice: '削除しました' }
      format.json { render json: { deleted_id: deleted_id } }
    end
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

  # API用のHistory情報を組み立てる。
  def build_history_payload(history)
    {
      id: history.id,
      target_date: history.target_date&.to_s,
      show_path: history_path(history),
      favorited: history.favorited_by?(current_user)
    }
  end

  # 閲覧モーダル用のHistory詳細情報を組み立てる。
  def build_history_detail_payload(history)
    {
      id: history.id,
      title: history.title,
      content_html: helpers.markdown(history.content),
      target_date: history.target_date&.to_s,
      target_date_label: helpers.dispdate(history.target_date, true),
      about_date: history.about_date,
      author_name: history.author&.dispname,
      member_label: history.member_label,
      member_names: history.member_names,
      eyecatch_url: history.eyecatch_image.attached? ? url_for(history.eyecatch_image_large) : nil,
      favorited: history.favorited_by?(current_user),
      height: history.height,
      weight: history.weight
    }
  end
end
