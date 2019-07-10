require 'carrierwave/orm/activerecord'

class DocumentUploader < CarrierWave::Uploader::Base
  storage :aws

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def store_dir
    "public/documents/#{model.class.name.downcase}/#{model.id}/#{mounted_as}/"
  end

  def extension_white_list
    %w(jpg jpeg gif png pdf doc docx xlsx)
  end

  def filename
    original_filename
  end
end
