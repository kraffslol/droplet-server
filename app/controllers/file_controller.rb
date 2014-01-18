class FileController < ApplicationController
  before_action :authenticate_with_basic_auth, only: :delete
  skip_before_filter :verify_authenticity_token
  include ApplicationHelper

  def view
    file = Upload.where(slug: params[:id]).last
    if(file)
      @file = file
    else
      render :nothing => true, :status => 404
    end
  end

  def delete
    file = Upload.where(slug: params[:id], userid: current_user).last
    if(file)
      # Delete
      obj = get_s3_object(Rails.application.config.s3_bucket, file.filename)
      obj.delete
      file.destroy
      render :nothing => true, :status => 200
    else
      render :nothing => true, :status => 404
    end
  end

  def redirect
    file = Upload.where(slug: params[:id]).last
    if(file)
      redirect_to "http://f.droplet.pw/" + file.filename
    else
      render :nothing => true, :status => 404
    end
  end
end
