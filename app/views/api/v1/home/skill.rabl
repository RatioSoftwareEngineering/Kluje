object @skill

attributes :id, :name, :description

node :job_categories do |skill|
  partial 'api/v1/home/job_categories', object: skill.job_categories
end

# for some reason creaties object_root for each child
# child :job_categories do
#   extends 'api/v1/home/job_categories'
# end
