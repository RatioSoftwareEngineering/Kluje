CarrierWave.configure do |config|
  config.storage    = :aws
  config.fog_public = true
  config.aws_acl    = :public_read
  # config.asset_host = 's3-ap-southeast-1.amazonaws.com'
  # config.aws_authenticated_url_expiration = 60 * 60 * 24 * 365

  if Rails.env == 'development' || Rails.env == 'test'
     config.aws_bucket = 'kluje-development'
     config.aws_credentials = {
       aws_access_key_id: Kluje.settings['aws']['access_key_id'],
       aws_secret_access_key: Kluje.settings['aws']['secret_access_key'],
       s3_endpoint: 's3-ap-southeast-1.amazonaws.com'
    }
  else
    if Kluje.settings['assets']
      config.asset_host = Kluje.settings['assets']['s3']
    end

    config.aws_credentials = {
      use_iam_profile: true,
      s3_endpoint: 's3-ap-southeast-1.amazonaws.com'
    }
    if Rails.env == "production"
      config.aws_bucket = 'kluje'
    else
      config.aws_bucket = 'kluje-staging'
    end
  end
end
