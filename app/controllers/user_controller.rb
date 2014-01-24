class UserController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def new
    if params.has_key?(:email) && params.has_key?(:password)
      user = User.create(login: params[:email], hashed_password: params[:password])
      if user.save
        render json: { "id" => user.id, "email" => params[:email]}, status: 201
      else
        render nothing: true
      end
    else
      render nothing: true
    end
  end
end