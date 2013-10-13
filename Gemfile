source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '4.0.0'

# Servers
gem 'puma'
gem 'unicorn'

gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-github'

# Multi-environment configuration
# gem 'simpleconfig'

# API
# gem 'rabl'

# ORM
gem 'mysql2'

# FORM
#gem 'simple_form', github: 'plataformatec/simple_form', branch: 'master'
gem 'simple_form', :git => 'https://github.com/plataformatec/simple_form.git'

# Performance and Exception management
# gem 'airbrake'
# gem 'newrelic_rpm'

# Security
# gem 'secure_headers'

# Miscellanea
# gem 'google-analytics-rails'
# gem 'haml'
# gem 'http_accept_language'
gem 'jquery-rails'
gem 'nokogiri'
gem 'sanitize'
# gem 'resque', require: 'resque/server' # Resque web interface

# Assets
gem 'coffee-rails', '~> 4.0.0'
gem 'select2-rails'
gem 'tinymce-rails'
# gem 'haml_assets'

# gem 'handlebars_assets'
gem 'i18n-js'
gem 'jquery-turbolinks'
gem 'less-rails'
gem 'sass-rails', '~> 4.0.0'
gem 'therubyracer'
gem 'turbolinks'
#gem 'twitter-bootstrap-rails', github: 'diowa/twitter-bootstrap-rails', branch: 'fontawesome-3.2.1'
gem 'less-rails-bootstrap'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'delorean'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'pry'
  gem 'pry-rails'
end

group :development do
  gem 'bullet'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'email_spec'
  gem 'launchy'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov', require: false
  gem 'webmock', require: false
end

group :staging, :production do
  gem 'rails_12factor'
end
