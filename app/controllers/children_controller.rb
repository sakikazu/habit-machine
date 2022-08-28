class ChildrenController < ApplicationController
  before_action :authenticate_user!
  before_action :set_child, only: %i[graph]
  before_action :set_view_setting

  def index
    @children = Child.all
  end

  def graph
    @graph = Children::ChartBuilder.new(@child).run
  end

  private

  def set_child
    @child = Child.find(params[:id])
  end

  def set_view_setting
    @no_header_margin = true
  end
end
