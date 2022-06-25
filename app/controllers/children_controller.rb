class ChildrenController < ApplicationController
  def index
    @children = Child.all
  end

  def show
    @month = if params[:month].present?
              Date.parse("#{params[:month]}-1") rescue Date.today
            else
              Date.today
            end
    @child = Child.find(params[:id])
    @histories = @child.child_histories.includes(:author).where(target_date: [@month.beginning_of_month..@month.end_of_month]).order(target_date: :asc)
    @history = @child.child_histories.build

    @no_header_margin = true
  end
end
