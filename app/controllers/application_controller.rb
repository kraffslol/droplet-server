class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_with_basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.authenticated?(username, password)
    end
  end

  helper_method :current_user
  def current_user
    @current_user
  end
end
