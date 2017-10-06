class SessionsController < ApplicationController
  before_action :no_user_allowed, only: [:new]

  def new
    set_redirect(came_from_root?)
  end

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticate(params[:session][:password])
      session[:user_id] = @user.id
      redirect_to session[:redirect]
    else
      render :new
    end
  end

  def destroy
    set_redirect
    session[:user_id] = nil
    redirect_to session[:redirect]
  end

  private

  def came_from_root?
    request.referrer == root_url
  end
end
