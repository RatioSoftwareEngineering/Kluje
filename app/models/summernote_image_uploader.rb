require 'securerandom'

class SummernoteImageUploader < ImageUploader
  def store_dir
    "public/images/summernote/#{SecureRandom.hex}/"
  end
end
