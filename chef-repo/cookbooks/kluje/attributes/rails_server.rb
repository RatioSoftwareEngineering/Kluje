# nginx
normal['nginx']['version'] = '1.8.1'
normal['nginx']['dir'] = '/etc/nginx'
normal['nginx']['log_dir'] = '/var/log/nginx'
normal['nginx']['binary'] = "/opt/nginx-#{node['nginx']['version']}/sbin"
normal['nginx']['source']['sbin_path'] = "#{node['nginx']['binary']}/nginx"
normal['nginx']['init_style'] = 'init'
normal['nginx']['default_site_enabled'] = false
normal['nginx']['source']['version'] = node['nginx']['version']
normal['nginx']['source']['modules'] = ['nginx::http_stub_status_module',
                                        'nginx::http_ssl_module',
                                        'nginx::http_gzip_static_module',
                                        'nginx::passenger']
normal['nginx']['source']['prefix'] = "/opt/nginx-#{node['nginx']['source']['version']}"
normal['nginx']['source']['default_configure_flags'] = ["--prefix=#{node['nginx']['source']['prefix']}",
                                                        "--conf-path=#{node['nginx']['dir']}/nginx.conf",
                                                        "--sbin-path=#{node['nginx']['source']['sbin_path']}"]
normal['nginx']['source']['url'] = "http://nginx.org/download/nginx-#{node['nginx']['source']['version']}.tar.gz"
normal['nginx']['source']['checksum'] = '8f4b3c630966c044ec72715754334d1fdf741caa1d5795fb4646c27d09f797b7'

# passenger
normal['nginx']['passenger']['version'] = '5.0.26'
normal['nginx']['passenger']['install_method'] = 'source'
normal['nginx']['passenger']['ruby'] = "#{node['rvm']['root_path']}/wrappers/ruby-#{node['rvm']['default_ruby']}/ruby"
normal['nginx']['passenger']['gem_binary'] = "#{node['rvm']['root_path']}/wrappers/ruby-#{node['rvm']['default_ruby']}/gem"
normal['nginx']['passenger']['root'] = "#{node['rvm']['root_path']}/gems/ruby-#{node['rvm']['default_ruby']}/gems/passenger-#{node['nginx']['passenger']['version']}"
normal['nginx']['configure_flags'] = ["--add-module=#{node['rvm']['root_path']}/gems/ruby-#{node['rvm']['default_ruby']}/gems/passenger-#{node['nginx']['passenger']['version']}/src/nginx_module"]
normal['nginx']['passenger']['packages']['debian'] = ['libcurl4-gnutls-dev']

# project
default['kluje']['rvm_path'] = "#{node['rvm']['root_path']}/gems/ruby-#{node['rvm']['default_ruby']}/bin:#{node['rvm']['root_path']}/gems/ruby-#{node['rvm']['default_ruby']}@global/bin:#{node['rvm']['root_path']}/rubies/ruby-#{node['rvm']['default_ruby']}/bin"
default['kluje']['project_dir'] = "/var/proj/kluje-#{node.chef_environment}"
default['kluje']['server_url'] = 'kluje.com' # without www!
