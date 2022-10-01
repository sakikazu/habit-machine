class ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_to_have_family
  before_action :set_child, only: %i[edit update destroy graph]
  before_action :set_content_title, only: [:edit, :graph]
  before_action :set_view_setting, only: %i(graph)

  def index
    @users = current_family.users
    @children = current_family.children.all
    @content_title = 'こども一覧'
  end

  def new
    @child = current_family.children.build
  end

  def create
    @child = Child.new(child_params)
    @child.family = current_family

    respond_to do |format|
      if @child.save
        format.html { redirect_to children_path, notice: 'こどもデータを作成しました.' }
      else
        format.html { render action: :new }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @child.update_attributes(child_params)
        format.html { redirect_to children_path, notice: 'こどもデータを更新しました.' }
      else
        format.html { render action: :edit }
      end
    end
  end

  def destroy
    @child.histories.destroy_all
    @child.destroy

    respond_to do |format|
      format.html { redirect_to children_path, notice: 'こどもデータを削除しました.' }
    end
  end

  def graph
    @graph = Children::ChartBuilder.new(@child).run
    @month = Time.zone.today
  end

  private

  def set_child
    @child = current_family.children.find(params[:id])
  end

  def set_content_title
    @content_title = @child.present? ? @child.name : 'こども'
  end

  def ensure_to_have_family
    redirect_to root_path, notice: '他の家族を有効にするフラグをONにしてください' unless current_family.has_others
  end

  def child_params
    params.require(:child).permit(:name, :birthday, :gender)
  end

  def set_view_setting
    @no_header_margin = true
  end
end
