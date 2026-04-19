class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]

  def index
    @projects = Current.user.projects.chronologically
  end

  def show
  end

  def new
    @project = Current.user.projects.build
  end

  def edit
  end

  def create
    @project = Current.user.projects.build(project_params)
    if @project.save
      redirect_to carreer_path, notice: "Project added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to carreer_path, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy!
    redirect_to carreer_path, notice: "Project removed."
  end

  private

    def set_project
      @project = Current.user.projects.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :year, :title, :description, :stack, :github_url)
    end
end
