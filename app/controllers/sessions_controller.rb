class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    user = User.find_by(email: session_params[:email].to_s.downcase.strip)
    if user&.authenticate(session_params[:password])
      start_new_session_for(user)
      redirect_to user_url(user)
    else
      flash.now[:alert] = "Try another email address or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, notice: "Signed out."
  end

  private

    def session_params
      params.require(:session).permit(:email, :password)
    end

end
