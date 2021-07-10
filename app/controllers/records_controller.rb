class RecordsController < ApplicationController
  before_action :authenticate_user!

  # TODO: ログインさえしてたら他人のRecordも記録できる状態なので修正する
  def create
    @record = Record.new(record_params)

    if @record.save
      render partial: 'show', locals: { record: @record }
    else
      render json: { message: @record.errors.full_messages.join('\n') }, status: :bad_request
    end
  end

  def update
    @record = Record.find(params[:id])

    if @record.update(record_params)
      render partial: 'show', locals: { record: @record }
    else
      render json: { message: @record.errors.full_messages.join('\n') }, status: :bad_request
    end
  end

  private

  def record_params
    params.require(:record).permit(:habit_id, :record_at, :value, :memo)
  end
end
