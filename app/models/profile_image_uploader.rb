require 'carrierwave/orm/activerecord'
class ProfileImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick
  include CarrierWave::ImageOptimizer

  storage :aws

  process resize_to_limit: [400, 304]
  process optimize: [{ quality: 85 }]

  def store_dir
    "public/images/#{model.id}/"
  end

  def default_url
    ActionController::Base.helpers.asset_path('contractor/profile_logo.png')
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
