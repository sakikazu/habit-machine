class HabitodosController < ApplicationController
  before_action :set_habitodo, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /habitodos
  def index
    # todo turbolinksとvue.jsの共存をしっかり理解して外せるようにしたい
    @turbolinks_off = true
  end

  def get_data
    habitodos = Habitodo.all.order('order_number DESC')
    render json: {
      status: 200,
      data: habitodos
    }
  end

  # GET /habitodos/1/edit
  def edit
    # todo 現在、タイトル変更のために使っている
  end

  # POST /habitodos
  def create
    @habitodo = Habitodo.new(habitodo_params)
    @habitodo.generate_uuid
    @habitodo.user = current_user
    # title は必須でいいよな？エラー時はalert

    if @habitodo.save
      render json: {
        status: 200,
        data: @habitodo
      }
    else
      # todo
      render :new
    end
  end

  # PATCH/PUT /habitodos/1
  def update
    if @habitodo.update(habitodo_params)
      render json: {
        status: 200,
        data: @habitodo
      }
    else
      # todo
      render :edit
    end
  end

  # DELETE /habitodos/1
  def destroy
    id = @habitodo.id
    @habitodo.destroy
    render json: {
      status: 200,
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_habitodo
      @habitodo = Habitodo.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def habitodo_params
      params.require(:habitodo).permit(:title, :body, :order_number)
    end
end
