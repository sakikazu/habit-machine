class RecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_record, only: %i[update destroy]

  def create
    habit = Habit.available_by_user(current_user).find(record_params[:habit_id])
    @record = habit.records.new(record_params.except(:habit_id))

    if @record.save
      render partial: 'show', locals: { record: @record }
    else
      render json: { message: @record.errors.full_messages.join("\n") }, status: :bad_request
    end
  end

  def update
    if @record.update(record_params.except(:habit_id))
      render partial: 'show', locals: { record: @record }
    else
      render json: { message: @record.errors.full_messages.join("\n") }, status: :bad_request
    end
  end

  # 指定された記録を削除する
  def destroy
    @record.destroy!
    head :no_content
  end

  private

  def record_params
    params.require(:record).permit(:habit_id, :record_at, :value, :memo)
  end

  # 現在のユーザーが管理できる記録だけを取得する
  def set_record
    @record = Record.by_user_or_family(current_user).find(params[:id])
  end
end
