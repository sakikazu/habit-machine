class TodoProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_project, only: %i[ edit update destroy ]

  # GET /todo_projects or /todo_projects.json
  def index
    @todo_projects = TodoProject.all
  end

  # GET /todo_projects/new
  def new
    @todo_project = TodoProject.new
  end

  # GET /todo_projects/1/edit
  def edit
  end

  # POST /todo_projects or /todo_projects.json
  def create
    @todo_project = TodoProject.new(todo_project_params)
    @todo_project.source = current_user

    respond_to do |format|
      if @todo_project.save
        format.html { redirect_to todo_projects_path, notice: "Todo project was successfully created." }
        format.json { render :show, status: :created, location: @todo_project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @todo_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todo_projects/1 or /todo_projects/1.json
  def update
    respond_to do |format|
      if @todo_project.update(todo_project_params)
        format.html { redirect_to todo_projects_path, notice: "Todo project was successfully updated." }
        format.json { render :show, status: :ok, location: @todo_project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_projects/1 or /todo_projects/1.json
  def destroy
    @todo_project.destroy
    respond_to do |format|
      format.html { redirect_to todo_projects_url, notice: "Todo project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_todo_project
      @todo_project = TodoProject.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def todo_project_params
      params.require(:todo_project).permit(:title, :content, :source_id, :source_type)
    end
end
