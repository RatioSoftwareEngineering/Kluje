require 'carrierwave/orm/activerecord'

class PhotoUploader < CarrierWave::Uploader::Base
  storage :aws

  # TODO: move images to separate folders
  def store_dir
    "public/images/#{model.id}/"
    #    "public/images/#{model.class.name.downcase}/#{model.id}/#{mounted_as}/"
  end

  def extension_white_list
    %w(jpg jpeg gif png pdf doc docx xlsx)
  end

  def filename
    original_filename
  end
end
