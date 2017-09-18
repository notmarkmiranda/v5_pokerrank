class SessionsController < ApplicationController
  before_action :no_user_allowed, only: [:new]

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      redirect_to dashboard_path
    else
      render :new
    end
  end

  def destroy
    set_redirect
    session[:user_id] = nil
    redirect_to session[:redirect]
  end
end
