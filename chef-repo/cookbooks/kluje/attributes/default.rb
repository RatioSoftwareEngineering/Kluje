# rvm
normal['rvm']['rubies'] = ['2.1.9']
normal['rvm']['default_ruby'] = node['rvm']['rubies'].first
normal['rvm']['user_default_ruby'] = node['rvm']['default_ruby']
normal['rvm']['gems'][node['rvm']['default_ruby']] = [{name: 'bundler'}, {name: 'rake'}]
normal['rvm']['gem_package']['rvm_string'] = node['rvm']['default_ruby']
normal['rvm']['gpg']['keyserver'] = 'hkp://keys.gnupg.net'
normal['rvm']['gpg']['homedir'] = '/root'
normal['rvm']['install_rubies'] = true
