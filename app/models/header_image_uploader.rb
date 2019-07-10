require 'carrierwave/orm/activerecord'

class HeaderImageUploader < CarrierWave::Uploader::Base
  # include CarrierWave::RMagick
  include CarrierWave::RMagick

  storage :aws

  def default_url
    ActionController::Base.helpers.asset_path('contractor/profile_header.jpg')
  end

  def store_dir
    "public/images/#{model.id}/"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    original_filename
  end
  process resize_to_fill: [1140, 275]
end
