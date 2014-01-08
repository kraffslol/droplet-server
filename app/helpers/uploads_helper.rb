module UploadsHelper
  require 'openssl'
  require 'securerandom'
  require 'aws/s3'
  require 'mime/types'
  def generate_policy(options = {})
    bucket = options[:bucket]
    access_key_id = options[:access_key_id]
    secret_access_key = options[:secret_access_key]
    key = options[:key] || ''
    slug = options[:slug]
    redirect = options[:redirect] || '/'
    acl = options[:acl] || 'public-read'
    thetime = Time.now.getutc + 1*60*60
    expiration_date = thetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    max_filesize = options[:max_filesize] || 26214400 # 25 mb

    policy = Base64.encode64(
        "{'expiration': '#{expiration_date}',
        'conditions': [
        {'bucket': '#{bucket}'},
        ['starts-with', '$key', 'items/#{slug}/'],
        {'acl': '#{acl}'},
        {'success_action_redirect': '#{redirect}'},
        ['content-length-range', 0, #{max_filesize}]
      ]
    }").gsub(/\n|\r/, '')

    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), secret_access_key, policy)).gsub("\n","")
    return { :policy => policy, :signature => signature, :acl => acl, :redirect => redirect}
  end

  def random_string()
    return SecureRandom.urlsafe_base64(3)
  end

  def generate_upload_response(user)
    if user.uploadsleft > 0 or user.plan == 1
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
          "max_upload_size" => 26214400,
          "url" => 'http://f.droplet.pw',
          "AWSAccessKeyId" => access_key,
          "key" => key,
          "policy" => s3data[:policy],
          "signature" => s3data[:signature],
          "success_action_redirect" => s3data[:redirect],
          "acl" => s3data[:acl]
      }

      if user.plan.equal? 0
        resp["uploads_remaining"] = user.uploadsleft
      end
    else
      resp = {
          "uploads_remaining" => 0,
          "max_upload_size" => 26214400,
          "url" => 'http://f.droplet.pw'
      }
    end

    return resp
  end

  def generate_s3_response(slug, filename, bucket, key)
    resp = {
        "url" => request.protocol + request.host_with_port + "/" + slug,
        "name" => filename,
        "remote_url" => "http://" + bucket + "/" + key,
        "view_counter" => 0,
        "created_at" => "",
        "updated_at" => ""
    }
  end

  def get_s3_object(bucket, key)
    AWS.config(access_key_id: Rails.application.config.s3_access_key, secret_access_key: Rails.application.config.s3_secret_key, region: 'eu-west-1')
    s3 = AWS::S3.new
    return s3.buckets[bucket].objects[key]
  end

  def set_content_type(obj, filename)
    obj.copy_to(obj.key, :content_type => MIME::Types.type_for(filename).first.content_type, :acl => "public-read")
  end
end
