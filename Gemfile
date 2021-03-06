source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby "2.6.5"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '>= 4.3.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

#Upgrade action view for security reasons
gem 'actionview', '>= 5.1.6.2'

# Upgrade nokogiri
gem 'nokogiri',  '>= 1.10.8'

# Upgrade ffi
gem 'ffi', '>= 1.9.24'

# Upgrade loofah
gem 'loofah', '>= 2.3.1'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use webpack to bundle js
gem 'webpacker', '~> 4.x'

gem 'jquery-rails'

gem 'bootstrap', '~> 4.3.1'

#schedule occcurrences
gem 'ice_cube'

#user session and registration management
gem 'devise', '>= 4.7.1'

#add invitable to devise
gem 'devise_invitable'

#Jwt authentication management
gem 'knock'

#activity tracker
gem 'public_activity', '>= 1.6.3'

#translations for devise
gem 'devise-i18n'

#translations for rails
gem 'rails-i18n', '~> 5.1'

#authorizations
gem 'pundit'

#api serialization
gem 'fast_jsonapi'



#create excel templates with axlsx
gem 'rubyzip', '>= 1.3.0'
gem 'caxlsx'
gem 'caxlsx_rails'

#charting library
gem 'chartkick', '>= 3.3.0'

#glyphicons
gem 'bootstrap-glyphicons', '~> 0.0.1'

#japanese holidays dataset
gem 'holiday_jp'

#bulk insertion of data into active record
gem 'activerecord-import'

#group by date, timeseries for chartkick
gem 'groupdate'

#acts as taggable on 
gem 'acts-as-taggable-on'

#sidekiq for background tasks
gem 'sidekiq'

#OJ backend for faster json rendering
gem 'oj'

#multi json to always pick the fastest json backend 
gem 'multi_json'

#gem for importing popper js
gem 'popper_js', '~> 1.14.5'

#gem for sending mails from forms without AR
gem 'mail_form'

#caching with mem_cached
gem 'dalli'
gem 'memcachier'

#mini-profiler
gem 'rack-mini-profiler'

#pooling connection for dalli with puma
gem 'connection_pool'

#gem that handles unread/read records
gem 'unread'

#webkit html to pdf
gem 'wicked_pdf'

#memory measurement tools
gem 'memory_profiler'

#push notifications
gem 'rpush'

#geocoding
gem 'geocoder'

#use rack cache for static assets
gem 'rack-cache'

#prevent form spaming
gem 'invisible_captcha'

group :production do 
  gem 'newrelic_rpm'
  gem 'scout_apm'
  gem 'wkhtmltopdf-heroku', '2.12.4'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'sys-proctable', '1.1.5'
  gem 'derailed_benchmarks'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
