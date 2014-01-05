require 'aws/s3'
require 'mime/types'
class UploadsController < ApplicationController
  include UploadsHelper
  before_action :authenticate_with_basic_auth

  # GET /new
  def new
    user = User.find_by_id(current_user)
    if (user.uploadsleft > 0)
      slug = random_string
      key = 'items/' + slug + '/${filename}'
      # Get keys from config in development.rb
      access_key = Rails.application.config.s3_access_key
      secret_key = Rails.application.config.s3_secret_key
      bucket = Rails.application.config.s3_bucket

      options = {
          :bucket => bucket,
          :access_key_id => access_key,
          :secret_access_key => secret_key,
          :key => key,
          :slug => slug,
          :redirect => request.protocol + request.host_with_port + '/items/s3'
      }
      #Generate s3 policy data
      s3data = generate_policy(options)

      resp = {
          "uploads_remaining" => user.uploadsleft,
          "max_upload_size" => 26214400,
          "url" => 'http://f.droplet.pw',
          "AWSAccessKeyId" => access_key,
          "key" => key,
          "policy" => s3data[:policy],
          "signature" => s3data[:signature],
          "success_action_redirect" => s3data[:redirect],
          "acl" => s3data[:acl]
      }

      render json: resp
    else
      resp = {
          "uploads_remaining" => 0,
          "max_upload_size" => 26214400,
          "url" => 'http://f.droplet.pw'
      }
      render json: resp
    end

  end

  def s3
    if params[:bucket] == 'f.droplet.pw' && params[:key] && params[:etag]
      # If file doesnt exist in db
      if(!Upload.find_by filename: params[:key])
        AWS.config(access_key_id: Rails.application.config.s3_access_key, secret_access_key: Rails.application.config.s3_secret_key, region: 'eu-west-1')
        s3 = AWS::S3.new
        obj = s3.buckets[params[:bucket]].objects[params[:key]]
        # If file exists in bucket.
        if obj.exists?
          filename = params[:key][11..-1]
          slug = params[:key][6..9]

          # Set content type.
          obj.copy_to(obj.key, :content_type => MIME::Types.type_for(filename).first.content_type, :acl => "public-read")

          # Add file to table.
          if(Upload.create(filename: params[:key], slug: slug, views: 0))
            User.where('id = ?', current_user).update_all("uploadsleft = uploadsleft - 1")
            resp = {
                "url" => request.protocol + request.host_with_port + "/" + slug,
                "name" => filename,
                "remote_url" => "http://" + params[:bucket] + "/" + params[:key],
                "view_counter" => 0,
                "created_at" => "",
                "updated_at" => ""
            }
            render json: resp
          else
            redirect_to '/'
          end
        end
      end
    end
  end

end
