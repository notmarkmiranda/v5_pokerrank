class UsersController < ApplicationController
  before_action :require_user, except: [:new, :create]
  before_action :load_user, only: [:show, :edit, :update]
  before_action :no_user_allowed, only: [:new]

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to dashboard_path
    else
    end
  end

  def update
    if @user.update(user_params)
      redirect_to dashboard_path
    else
    end
  end

  private

  def load_user
    @user = User.find(session[:user_id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
