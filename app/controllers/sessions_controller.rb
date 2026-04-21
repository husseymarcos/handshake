class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    professional = Professional.find_by(email: session_params[:email].to_s.downcase.strip)
    if professional&.authenticate(session_params[:password])
      start_new_session_for(professional)
      redirect_to root_url
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to signin_path, notice: "Signed out."
  end

  private

    def session_params
      params.require(:session).permit(:email, :password)
    end
end
