class FamiliesController < ApplicationController
  before_action :authenticate_user!

  def show
    @users = current_family.users
    @children = current_family.children
    @histories_count_hash = build_histories_count_hash(current_family)
    @content_title = '家族ページ'
  end

  def edit
  end

  def update
    current_family.update(family_params)
    redirect_to family_path, notice: '更新しました'
  end

  private

  def family_params
    params.require(:family).permit(:name)
  end

  def build_histories_count_hash(family)
    {
      children: family.children.includes(:histories).map { [_1.id, _1.histories.count] }.to_h,
      users: family.users.includes(:histories).map { [_1.id, _1.histories.count] }.to_h,
      family: family.histories.count
    }
  end
end
