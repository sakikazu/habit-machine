class HabitodosController < ApplicationController
  before_action :set_habitodo, only: [:update, :destroy]
  before_action :authenticate_user!

  # GET /habitodos
  def index
    @page_title = 'Habitodo'
    @no_header_margin = true
  end

  def get_data
    @habitodos = current_user.habitodos.select(:uuid, :title, :body, :order_number)
  end

  # POST /habitodos
  def create
    @habitodo = Habitodo.new(habitodo_params)
    @habitodo.generate_uuid
    @habitodo.user = current_user
    # title は必須でいいよな？エラー時はalert

    if @habitodo.save
      render partial: 'show', locals: { habitodo: @habitodo }
    else
      render json: { message: '作成に失敗しました' }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /habitodos/1
  def update
    if @habitodo.update(habitodo_params)
      render partial: 'show', locals: { habitodo: @habitodo }
    else
      render json: { message: @habitodo.errors.full_messages.join("\n") }, status: :unprocessable_entity
    end
  end

  # DELETE /habitodos/1
  def destroy
    @habitodo.destroy
    head :ok
  end

  private

  def set_habitodo
    @habitodo = Habitodo.find_by_uuid(params[:id])
  end

  def habitodo_params
    params.require(:habitodo).permit(:title, :body, :order_number)
  end
end
