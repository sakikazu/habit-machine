class ChildHistoriesController < ApplicationController
  before_action :set_child_history, only: [:edit, :update, :destroy]

  def index
    @child = Child.find(params[:child_id])
    redirect_to child_path(@child)
  end

  def create
    @child = Child.find(params[:child_id])
    @history = @child.child_histories.build(child_history_params)
    set_data_if_need
    @history.author = current_user
    unless @history.save
      @month = @history.target_date
      render 'children/show'
      return
    end
    redirect_to child_path(@child, month: @history.target_date.strftime("%Y-%m"), anchor: "history-#{@history.target_date.strftime('%Y-%m-%d')}")
  end

  def edit
    if @history.data.present?
      history_data = @history.data.with_indifferent_access
      @history.height = history_data[:height]
      @history.weight = history_data[:weight]
    end
  end

  def update
    set_data_if_need
    unless @history.update(child_history_params)
      @month = @history.target_date
      render 'children/show'
      return
    end
    redirect_to child_path(@history.child, month: @history.target_date.strftime("%Y-%m"), anchor: "history-#{@history.target_date.strftime('%Y-%m-%d')}")
  end

  def destroy
    target_date = @history.target_date
    child = @history.child
    @history.destroy
    redirect_to child_path(@history.child, month: target_date.strftime("%Y-%m"))
  end

  private

  def set_child_history
    @history = ChildHistory.find(params[:id])
  end

  def child_history_params
    params.require(:child_history).permit(:title, :content, :image, :as_profile_image, :target_date, :about_date)
  end

  def set_data_if_need
    if params[:child_history][:height].present? || params[:child_history][:weight].present?
      @history.data = {
        height: params[:child_history][:height],
        weight: params[:child_history][:weight]
      }
    end
  end
end
