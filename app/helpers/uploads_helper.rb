module UploadsHelper
  require 'openssl'
  require 'securerandom'
  def generate_policy(options = {})
    bucket = options[:bucket]
    access_key_id = options[:access_key_id]
    secret_access_key = options[:secret_access_key]
    key = options[:key] || ''
    redirect = options[:redirect] || '/'
    acl = options[:acl] || 'public-read'
    thetime = Time.now.getutc + 1*60*60
    expiration_date = thetime.strftime('%Y-%m-%dT%H:%M:%SZ')
    max_filesize = options[:max_filesize] || 671088640 # 5 gb

    policy = Base64.encode64(
        "{'expiration': '#{expiration_date}',
        'conditions': [
        {'bucket': '#{bucket}'},
        ['starts-with', '$key', '#{key}'],
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
end
