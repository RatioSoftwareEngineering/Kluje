require 'carrierwave/orm/activerecord'

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  storage :aws

  def default_url
    ''
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
end
