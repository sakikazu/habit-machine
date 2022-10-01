class FamiliesController < ApplicationController
  before_action :authenticate_user!

  def show
    @users = current_family.users
    @children = current_family.children.all
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
end
