class ExperiencesController < ApplicationController
  before_action :set_experience, only: %i[ show edit update destroy ]

  def index
    @experiences = Current.professional.experiences.chronologically
  end

  def show
  end

  def new
    @experience = Current.professional.experiences.build
  end

  def edit
  end

  def create
    @experience = Current.professional.experiences.build(experience_params)
    if @experience.save
      redirect_to career_path, notice: "Experience added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @experience.update(experience_params)
      redirect_to career_path, notice: "Experience updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @experience.destroy!
    redirect_to career_path, notice: "Experience removed."
  end

  private

    def set_experience
      @experience = Current.professional.experiences.find(params[:id])
    end

    def experience_params
      params.require(:experience).permit(:name, :year, :title, :description, :stack, :github_url)
    end
end
