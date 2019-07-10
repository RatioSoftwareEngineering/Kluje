# See http://docs.opscode.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name 'thanhphat'
client_key               "#{ENV['HOME']}/.chef/thanhphat.pem"
validation_client_name 'kluje-validator'
validation_key           "#{ENV['HOME']}/.chef/kluje-validator.pem"
chef_server_url 'https://api.opscode.com/organizations/kluje'
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]

knife[:aws_credential_file] = "#{ENV['HOME']}/.chef/kluje.aws.credentials"
knife[:region] = 'ap-southeast-1'
knife[:editor] = 'vim'
knife[:secret_file] = '/etc/chef/kluje_secret'
