secret = Chef::EncryptedDataBagItem.load_secret("/etc/chef/encrypted_data_bag_secret")
license_key = Chef::EncryptedDataBagItem.load("keys", "sendy", secret)['license']
db_config = Chef::EncryptedDataBagItem.load("config", "database", secret)['sendy']

['php5-fpm', 'php5-mysql', 'php5-cli'].each do |pkg|
  package pkg
end

remote_file "/tmp/sendy.zip" do
  source "https://sendy.co/download/?license=#{license_key}"
  owner 'ubuntu'
  group 'ubuntu'
  action :create_if_missing
end

directory '/var/proj/sendy' do
  owner 'ubuntu'
  group 'ubuntu'
end

execute 'unzip sendy' do
  command 'unzip -n /tmp/sendy.zip -d /var/proj -x *includes/config*'
end

template '/var/proj/sendy/includes/config.php' do
  source 'sendy.php.erb'
  owner 'ubuntu'
  group 'ubuntu'
  action :create
  variables({db: db_config})
  notifies :reload, "service[nginx]", :delayed
end

cron 'sendy_scheduler' do
  minute '*/5'
  command '/usr/bin/php /var/proj/sendy/scheduled.php > /dev/null 2>&1'
end
