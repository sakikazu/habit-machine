class ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child, only: %i[edit update destroy graph]
  before_action :set_content_title, only: [:edit, :graph]

  def new
    @child = current_family.children.build
  end

  def create
    @child = Child.new(child_params)
    @child.family = current_family

    respond_to do |format|
      if @child.save
        format.html { redirect_to settings_family_path, notice: 'こどもデータを作成しました.' }
      else
        format.html { render action: :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @child.update(child_params)
        format.html { redirect_to settings_family_path, notice: 'こどもデータを更新しました.' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @child.histories.destroy_all
    @child.destroy

    respond_to do |format|
      format.html { redirect_to settings_family_path, notice: 'こどもデータを削除しました.' }
    end
  end

  def graph
    @graph = Children::ChartBuilder.new(@child).run
  end

  private

  def set_child
    @child = current_family.children.find(params[:id])
  end

  def set_content_title
    child_name = @child.present? ? @child.name : 'こども'
    @content_title = action_name == 'graph' ? "#{child_name}の身長・体重グラフ" : child_name
  end

  def child_params
    params.require(:child).permit(:name, :birthday, :gender)
  end
end
