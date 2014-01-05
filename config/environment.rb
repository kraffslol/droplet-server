# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Droplet::Application.initialize!

AWS::S3::DEFAULT_HOST = "s3-eu-west-1.amazonaws.com"