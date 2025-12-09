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
end
