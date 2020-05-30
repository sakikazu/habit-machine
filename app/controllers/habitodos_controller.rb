class HabitodosController < ApplicationController
  before_action :set_habitodo, only: [:update, :destroy]
  before_action :authenticate_user!

  # GET /habitodos
  def index
    # todo turbolinksとvue.jsの共存をしっかり理解して外せるようにしたい
    # これをやらないと（つまりbodyでturbolinks:falseにしないと）、他のページでもhabitodos.jsが実行されてしまう
    # Vue.jsの実行を、特定要素がある場合のみ、と条件付けすれば問題はないが、良くはないのでtrueとしとく
    # 理論はよくわかってない
    @turbolinks_off = true
    @page_title = 'Habitodo'
  end

  def get_data
    habitodos = Habitodo.all
    render json: {
      status: 200,
      data: habitodos
    }
  end

  # POST /habitodos
  def create
    @habitodo = Habitodo.new(habitodo_params)
    @habitodo.generate_uuid
    @habitodo.user = current_user
    # title は必須でいいよな？エラー時はalert

    if @habitodo.save
      render json: @habitodo
    else
      # todo
      render :new
    end
  end

  # PATCH/PUT /habitodos/1
  def update
    if @habitodo.update(habitodo_params)
      render json: @habitodo
    else
      # todo
      render :edit
    end
  end

  # DELETE /habitodos/1
  def destroy
    @habitodo.destroy
    render json: ''
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_habitodo
      @habitodo = Habitodo.find_by_uuid(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def habitodo_params
      params.require(:habitodo).permit(:title, :body, :order_number)
    end
end
