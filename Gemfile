source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'jquery-rails'

gem 'bootstrap', '~> 4.3.1'

#schedule occcurrences
gem 'ice_cube'

#user session and registration management
gem 'devise'

#add invitable to devise
gem 'devise_invitable'

#activity tracker
gem 'public_activity'

#translations for devise
gem 'devise-i18n'

#translations for rails
gem 'rails-i18n', '~> 5.1'

#authorizations
gem 'pundit'

#japanese text conversions
gem 'miyabi'

#japanese dates
gem 'wareki'

#create excel templates with axlsx
gem 'rubyzip', '>= 1.2.2'
gem 'axlsx', git: 'https://github.com/randym/axlsx.git', ref: 'c8ac844'
gem 'axlsx_rails'

#charting library
gem "chartkick"

#glyphicons
gem 'bootstrap-glyphicons', '~> 0.0.1'

#japanese holidays dataset
gem 'holiday_jp'

#bulk insertion of data into active record
gem 'activerecord-import'

#group by date, timeseries for chartkick
gem 'groupdate'

#selectize for checkboxes
gem 'selectize-rails'

#acts as taggable on 
gem 'acts-as-taggable-on'

#sidekiq for background tasks
gem 'sidekiq'

#OJ backend for faster json rendering
gem 'oj'

#multi json to always pick the fastest json backend 
gem 'multi_json'

# carrierwave and fog AWS to upload and permanently store files
gem 'carrierwave'
gem 'fog-aws'

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

group :production do 
  gem 'wkhtmltopdf-heroku'
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
  gem 'web-console', '>= 3.3.0'
end

gem 'rails_12factor', group: :production

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
