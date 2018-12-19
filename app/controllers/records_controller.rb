class RecordsController < ApplicationController
  before_action :set_record, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  def update_or_create
    # idではなくhabit_id, record_atでfindしている理由は、まだDBにない状態でフォーム編集し、その直後に再度そこのフォームを編集した場合、idが付加されていないので、idだとそのデータが特定できなくなるため
    @record = Record.find_by_habit_id_and_record_at(params[:habit_id], params[:record_at])

    if @record
      @record.update_attributes(record_params)
    else
      @record = Record.new(record_params)
      @record.save
    end
    # best_in_place専用のjson formatレンダー
    respond_with_bip(@record)
  end

  # GET /records/new
  # GET /records/new.json
  def new
    @record = Record.new(habit_id: params[:habit_id], record_at: params[:record_at])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @record }
    end
  end

  # GET /records/1/edit
  def edit
  end

  # POST /records
  # POST /records.json
  def create
    @record = Record.new(record_params)

    respond_to do |format|
      if @record.save
        format.html { redirect_to @record, notice: 'Record was successfully created.' }
        format.json { render json: @record, status: :created, location: @record }
      else
        format.html { render action: "new" }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /records/1
  # PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update_attributes(record_params)
        format.html { redirect_to @record, notice: 'Record was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy

    respond_to do |format|
      format.html { redirect_to records_url }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = Record.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    params[:record][:habit_id] = params[:habit_id] if params[:habit_id].present?
    params[:record][:record_at] = params[:record_at] if params[:record_at].present?
    params.require(:record).permit(:habit_id, :record_at, :value, :memo)
  end

end
