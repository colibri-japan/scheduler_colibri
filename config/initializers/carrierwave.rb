require 'carrierwave/orm/activerecord'

CarrierWave.configure do |config|
  config.ignore_processing_errors = true
  config.fog_provider = 'fog/aws'                        # required
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     ENV['S3_KEY'] ,                        # required unless using use_iam_profile
    aws_secret_access_key: ENV['S3_SECRET'] ,                        # required unless using use_iam_profile
    region:                ENV['S3_REGION'] ,                  # optional, defaults to 'us-east-1'
  }
  config.fog_directory  = ENV['S3_BUCKET']      
  config.storage = :fog                              # required
end

begin
  # attaching code
rescue CarrierWave::ProcessingError => error
  raise error.cause
end