source 'https://rubygems.org'

ruby '2.1.9'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
gem 'mysql2'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'haml'

# Translation
gem 'gettext_i18n_rails'

# Necessary for Kluje Padrino integration
gem 'paranoia'
gem 'aws-sdk', '< 2'
gem 'twilio-ruby'
gem 'nexmo'
gem 'carrierwave'
gem 'carrierwave-aws'
gem 'rmagick'
gem 'mini_magick'
gem 'protected_attributes' # attr_accessible
gem 'state_machine'
gem 'settingslogic'
gem 'phony'
gem 'braintree'
gem 'geocoder'
gem 'geoip'
gem 'html_truncator', '~>0.2'
gem 'resque'
gem 'resque-scheduler'
gem 'resque_mailer'
gem 'resque-web', require: 'resque_web'
gem 'rack-timeout'
gem 'mandrill'
gem 'dalli'
gem 'rack-mini-profiler'

# View utilities
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# General
gem 'devise'
gem 'bcrypt'
gem 'cancancan'

# Social login
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'

# Admin
gem 'activeadmin', github: 'activeadmin'
gem 'ckeditor'

# Views
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-timepicker-rails'

# API
gem 'rabl'
gem 'koala'
gem 'gcm'
gem 'grocer'

# PDF
gem 'prawn'
gem 'prawn-table'

gem 'whenever', require: false
gem 'friendly_id', '~> 5.1.0'
gem 'punching_bag'

# search
gem 'ransack'
gem 'exception_notification'

group :development, :test do
  gem 'byebug'
  gem 'erb2haml'
  gem 'fast_gettext'
  gem 'gettext', '>=3.0.2'
  gem 'letter_opener'
  gem 'ruby_parser'
  gem 'rails-erd'
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'
  gem 'database_cleaner'

  # Use Capistrano for deployment
  gem 'capistrano-rails'
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rvm'
end

group :development do
  gem 'bullet'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'annotate'
  gem 'overcommit'
  gem 'fasterer'
  gem 'bundler-audit'
  gem 'rubocop', '0.35.1', require: false
  gem 'meta_request'
  gem 'rbnacl'
  gem 'bcrypt_pbkdf'
  gem 'rbnacl-libsodium'
end

group :test do
  # app-specific gems
  gem 'rspec-rails', '~> 3.5'

  gem 'shoulda-matchers', '~> 3.1'
  gem 'faker'
  gem 'factory_girl_rails', require: false
  gem 'capybara'
end

# simply optimize CarrierWave images via jpegoptim or optipng
gem 'carrierwave-imageoptimizer'
