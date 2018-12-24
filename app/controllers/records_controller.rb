class RecordsController < ApplicationController
  before_action :authenticate_user!

  def update_or_create
    # idではなくhabit_id, record_atでfindしている理由は、まだDBにない状態でフォーム編集し、その直後に再度そこのフォームを編集した場合、
    # idが付加されていないので、idだとそのデータが特定できなくなるため
    @record = Record.find_by_habit_id_and_record_at(params[:habit_id], params[:record_at])

    if @record
      @record.update_attributes(record_params)
    else
      @record = Record.new(record_params)
      @record.save
    end

    # NOTE: 入力がブランクの場合「未入力」と表示したいが、record.valueは0になってレスポンスされるので、明示するようにした
    if record_params[:value].blank? && record_params[:memo].blank?
      render json: {display_as: '未入力'}
    else
      # best_in_place専用のjson formatレンダー
      respond_with_bip(@record)
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    params[:record][:habit_id] = params[:habit_id] if params[:habit_id].present?
    params[:record][:record_at] = params[:record_at] if params[:record_at].present?
    params.require(:record).permit(:habit_id, :record_at, :value, :memo)
  end

end
