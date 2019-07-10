object @photo

attributes :id, :url, :job_id

node :url do |photo|
  photo.image_name_url
end

node :job_id do |photo|
  photo.job_id.to_i
end
