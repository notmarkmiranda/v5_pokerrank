class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :require_user

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def require_user
    redirect_to root_path unless current_user
  end

  def no_user_allowed
    redirect_to not_found_path if current_user
  end

  def set_redirect(from_root_and_login=false)
    if from_root_and_login
      session[:redirect] = dashboard_path
    else
      session[:redirect] = request.referrer || root_path
    end
  end
end
