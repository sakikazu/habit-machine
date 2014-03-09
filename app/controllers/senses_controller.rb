class SensesController < ApplicationController
  before_action :set_sense, only: [:show, :edit, :update, :destroy]

  # GET /senses
  def index
    # 終了日が現在以降のものを表示（startが未来のものも表示する）
    @senses = Sense.order("sort_order ASC").where("end_at >= ?", Date.today).where(user_id: current_user.id)
  end

  def past
    @senses = Sense.order("sort_order ASC").where("end_at <?", Date.today).where(user_id: current_user.id)
    render :index
  end

  # GET /senses/1
  # def show
  # end

  # GET /senses/new
  def new
    @sense = Sense.new
  end

  # GET /senses/1/edit
  def edit
  end

  # POST /senses
  def create
    @sense = Sense.new(sense_params)
    @sense.user_id = current_user.id

    if @sense.save
      redirect_to senses_url, notice: '作成しました.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /senses/1
  def update
    if @sense.update(sense_params)
      redirect_to senses_url, notice: '更新しました.'
    else
      render action: 'edit'
    end
  end

  # DELETE /senses/1
  def destroy
    @sense.destroy
    redirect_to senses_url, notice: '削除しました.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sense
      @sense = Sense.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def sense_params
      params.require(:sense).permit(:user_id, :title, :description, :content, :start_at, :end_at, :is_active, :sort_order)
    end
end
