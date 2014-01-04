class UploadsController < ApplicationController
  include UploadsHelper
  before_action :authenticate_with_basic_auth

  # GET /new
  def new
    key = 'items/' + random_string
    # Get keys from config in development.rb
    access_key = Rails.application.config.s3_access_key
    secret_key = Rails.application.config.s3_secret_key
    bucket = Rails.application.config.s3_bucket

    options = {
        :bucket => bucket,
        :access_key_id => access_key,
        :secret_access_key => secret_key,
        :key => key,
        :redirect => 'http://localhost:3000/s3'
    }
    s3data = generate_policy(options)

    resp = {
        "url" => 'http://s3-eu-west-1.amazonaws.com/f.droplet.pw',
        "AWSAccessKeyId" => secret_key,
        "key" => key,
        "policy" => s3data[:policy],
        "signature" => s3data[:signature],
        "success_action_redirect" => s3data[:redirect],
        "acl" => s3data[:acl]
    }

    render json: resp
  end

  def s3

  end
end
