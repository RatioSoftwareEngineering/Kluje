object @contractor

attributes :rating



node :name do |contractor|
  contractor.company_name
end

node :logo do |contractor|
  contractor.company_logo.url
end

node :url do |contractor|
  contractor.profile_url
end
