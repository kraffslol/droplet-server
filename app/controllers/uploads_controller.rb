require 'aws/s3'
require 'mime/types'
class UploadsController < ApplicationController
  include UploadsHelper
  before_action :authenticate_with_basic_auth

  # GET /new
  def new
    user = User.find_by_id(current_user)
    render json: generate_upload_response(user)
  end

  #GET /s3
  def s3
    if params[:bucket] == Rails.application.config.s3_bucket && params[:key] && params[:etag]
      # If file doesnt exist in db
      if(!Upload.find_by filename: params[:key])
        obj = get_s3_object(params[:bucket], params[:key])
        # If file exists in bucket.
        if obj.exists?
          filename = params[:key][11..-1]
          slug = params[:key][6..9]

          # Set content type.
          set_content_type(obj, filename)

          # Add file to table.
          if(Upload.create(filename: params[:key], slug: slug, views: 0, userid: current_user.id, filetype: get_filetype(filename)))
            User.decrement_remaininguploads(current_user)
            render json: generate_s3_response(slug, filename, params[:bucket], params[:key])
          else
            redirect_to '/'
          end
        end
      else
        redirect_to '/'
      end
    end
  end

end
