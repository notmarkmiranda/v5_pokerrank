class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  helper_method :require_user
  helper_method :came_from_somewhere?
  add_breadcrumb "Home", "/dashboard", if: :not_root_path?

  private

  def came_from_somewhere?
    !request.referrer.nil?
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user?
    current_user
  end

  def no_user_allowed
    redirect_to not_found_path if current_user
  end

  def not_root_path?
    request.fullpath != '/'
  end

  def require_user
    redirect_to root_path unless current_user
  end


  def set_redirect(from_root_and_login=false)
    if from_root_and_login
      session[:redirect] = dashboard_path
    else
      session[:redirect] = request.referrer || root_path
    end
  end
end
