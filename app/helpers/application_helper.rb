module ApplicationHelper
  def title(page_title)
    content_for :title, page_title.to_s
  end

  def get_s3_object(bucket, key)
    AWS.config(access_key_id: Rails.application.config.s3_access_key, secret_access_key: Rails.application.config.s3_secret_key, region: 'eu-west-1')
    s3 = AWS::S3.new
    return s3.buckets[bucket].objects[key]
  end
end
