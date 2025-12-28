class FavoritesController < ApplicationController
  before_action :authenticate_user!

  ALLOWED_TYPES = %w[Diary History].freeze

  def create
    favoritable = find_favoritable!
    return if performed?

    favorite = current_user.favorites.find_or_initialize_by(favoritable: favoritable)

    if favorite.persisted? || favorite.save
      render json: { favorited: true }
    else
      render json: { favorited: false, message: favorite.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  def index
    favorites = current_user.favorites.includes(:favoritable).order(created_at: :desc)

    @favorites = favorites.map do |favorite|
      favoritable = favorite.favoritable
      case favoritable
      when Diary
        {
          id: favoritable.id,
          type: 'Diary',
          title: favoritable.title.presence || '(タイトルなし)',
          date: favoritable.record_at,
          path: diary_with_date_path(date: favoritable.record_at, id: favoritable.id),
          member: nil,
          edit_path: edit_diary_path(favoritable),
          content: nil,
          favorited_at: favorite.created_at
        }
      when History
        {
          id: favoritable.id,
          type: 'History',
          title: favoritable.title.presence || '(タイトルなし)',
          date: favoritable.target_date,
          member: history_member_label(favoritable),
          path: history_show_path(favoritable),
          edit_path: history_edit_path(favoritable),
          content: favoritable.content,
          favorited_at: favorite.created_at
        }
      end
    end.compact

    respond_to do |format|
      format.json
    end
  end

  def destroy
    favoritable = find_favoritable!
    return if performed?

    favorite = current_user.favorites.find_by(favoritable: favoritable)

    if favorite&.destroy
      render json: { favorited: false }
    else
      render json: { favorited: false, message: 'favorite not found' }, status: :not_found
    end
  end

  # History向けの簡易追記
  def append_history
    history = History.find(params.require(:history_id))
    memo = params[:content].to_s.strip

    if memo.blank?
      render json: { message: '追記内容を入力してください' }, status: :unprocessable_entity and return
    end

    # 簡易なアクセス制御: 家族が異なる場合は拒否
    if history.family_id.present? && respond_to?(:current_family) && history.family_id != current_family&.id
      render json: { message: '権限がありません' }, status: :forbidden and return
    end

    # 末尾の空行を取り除き、文字のある最終行の直後に追記する
    existing = history.content.to_s.rstrip.presence
    new_content = [existing, memo].compact.join("\n")
    if history.update(content: new_content)
      render json: { history: { id: history.id, content: history.content } }
    else
      render json: { message: history.errors.full_messages.join(', ') }, status: :unprocessable_entity
    end
  end

  private

  def find_favoritable!
    type = params.require(:favoritable_type)
    id = params.require(:favoritable_id)
    unless ALLOWED_TYPES.include?(type)
      render json: { message: 'invalid favoritable_type' }, status: :bad_request and return
    end

    type.constantize.find(id)
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'favoritable not found' }, status: :not_found
  end

  def history_show_path(history)
    history_path(history)
  end

  def history_member_label(history)
    label = history.member_label
    label.presence || '家族'
  end

  def history_edit_path(history)
    edit_history_path(history)
  end
end
