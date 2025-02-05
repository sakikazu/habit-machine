class CategoriesController < ApplicationController
  before_action :set_category, only: %i[show edit update destroy]
  before_action :authenticate_user!

  def index
    # TODO: includes(source)で、shared?メソッドの中のN+1が解消できてないけどなぜだっけ
    @categories = current_user.all_categories.includes(:source, :children).where(parent_id: nil)
  end

  def show
  end

  def new
    @category = Category.new
    @shared = params[:shared].present?
    if params[:parent_id].present?
      @category.parent = current_user.all_categories.find(params[:parent_id])
    end
  end

  # TODO: showとかeditで、カテゴリに紐づく日記数とかを表示。とくにeditでは削除ができるので、そこを何か制限したい
  def edit
  end

  def create
    @category = Category.new(category_params)
    if params[:parent_id].present?
      @category.parent = current_user.all_categories.find(params[:parent_id])
    end
    # 親カテゴリがあれば、その共有設定を受け継ぐ
    @category.source = if params[:shared].present? || @category.parent&.shared?
                         current_user.family
                       else
                         current_user
                       end

    if @category.save
      redirect_to categories_path, notice: 'カテゴリを作成しました'
    else
      render :new
    end
  end

  # TODO: 親カテゴリの変更、共有設定の変更には未対応
  def update
    @category.update(category_params)
    redirect_to categories_path, notice: 'カテゴリを更新しました'
  end

  def destroy
    @category.destroy

    respond_to do |format|
      format.html { redirect_to categories_url, notice: 'カテゴリを削除しました.' }
      format.json { head :no_content }
    end
  end

  private

  def category_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = current_user.all_categories.find(params[:id])
  end
end
