class SensesController < ApplicationController
  before_action :set_sense, only: [:show, :edit, :update, :destroy]
  before_action :set_content_title, only: [:edit]
  before_action :authenticate_user!

  # GET /senses
  def index
    @senses = Sense.by_user(current_user).order("sort_order ASC").where(is_inactive: false)
  end

  # 終了日で自動判定でなく、is_inactiveを手動で設定することで判定するようにする
  def past
    @senses = Sense.by_user(current_user).order("sort_order ASC").where(is_inactive: true)
    @is_past = true
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
  def set_content_title
    @content_title = @sense.present? ? @sense.title : ""
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_sense
      @sense = Sense.by_user(current_user).find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def sense_params
      params.require(:sense).permit(:user_id, :title, :description, :content, :start_at, :end_at, :is_inactive, :sort_order)
    end
end
