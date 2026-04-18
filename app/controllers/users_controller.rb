class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  before_action :set_user, only: %i[ show edit update ]
  before_action :require_self, only: %i[ show edit update ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_create_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to @user
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.touch_blueprint!(user_update_params[:blueprint_typst].to_s)
      redirect_to @user, notice: "Library updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def require_self
      return if Current.user == @user

      redirect_to user_path(Current.user), alert: "That account is not yours."
    end

    def user_create_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def user_update_params
      params.require(:user).permit(:blueprint_typst)
    end
end
