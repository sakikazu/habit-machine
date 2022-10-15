class TodosController < ApplicationController
  before_action :set_todo, only: %i[ show edit update destroy ]
  skip_before_action :verify_authenticity_token, only: %i[google_callback]

  def google_callback
    refresh_token = Google::Calendar.new(session).fetch_access_token(code: params[:code])
    current_user.update(preferences: { google_refresh_token: refresh_token })
    redirect_to action: :index
  end

  # GET /todos or /todos.json
  def index
    @todos = Todo.all
    @calendar_events = Google::Calendar.new(session).fetch_recent_events_with_refreshing_token(current_user.preferences["google_refresh_token"])
    @auth_uri = Google::Calendar.new.auth_uri if session[:gcp_access_token].blank?
  rescue Google::Calendar::RefreshTokenExpiredError
    @auth_uri = Google::Calendar.new.auth_uri
  end

  # GET /todos/1 or /todos/1.json
  def show
  end

  # GET /todos/new
  def new
    @todo = Todo.new
  end

  # GET /todos/1/edit
  def edit
  end

  # POST /todos or /todos.json
  def create
    @todo = Todo.new(todo_params)

    respond_to do |format|
      if @todo.save
        format.html { redirect_to @todo, notice: "Todo was successfully created." }
        format.json { render :show, status: :created, location: @todo }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todos/1 or /todos/1.json
  def update
    respond_to do |format|
      if @todo.update(todo_params)
        format.html { redirect_to @todo, notice: "Todo was successfully updated." }
        format.json { render :show, status: :ok, location: @todo }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todos/1 or /todos/1.json
  def destroy
    @todo.destroy
    respond_to do |format|
      format.html { redirect_to todos_url, notice: "Todo was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo
      @todo = Todo.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_params
      params.require(:todo).permit(:title, :content, :state)
    end
end
