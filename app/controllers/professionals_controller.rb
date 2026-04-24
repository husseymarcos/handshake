class ProfessionalsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  layout "auth", only: %i[ new create ]

  before_action :set_professional, only: %i[ show edit update ]
  before_action :require_self, only: %i[ show edit update ]

  def new
    @professional = Professional.new
  end

  def create
    @professional = Professional.new(professional_create_params)
    if @professional.save
      start_new_session_for(@professional)
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @professional.update(professional_update_params)
      redirect_to career_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def set_professional
      @professional = params[:id] ? Professional.find(params[:id]) : Current.professional
    end

    def require_self
      return if Current.professional == @professional

      redirect_to career_path, alert: "That account is not yours."
    end

    def professional_create_params
      params.require(:professional).permit(:name, :email, :password, :password_confirmation)
    end

    def professional_update_params
      params.require(:professional).permit(:name, :email)
    end
end
