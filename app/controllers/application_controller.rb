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

  #Helper method to get the filename from s3 path.
  helper_method :get_filename
  def get_filename(file)
    return file[11..-1]
  end
end
