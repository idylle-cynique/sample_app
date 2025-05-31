source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "rails"
gem "image_processing"
gem "active_storage_validations"
gem "bootstrap-sass", "~> 3.4.1"
gem "sassc-rails"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "puma"
gem "bootsnap", require: false
gem "bcrypt"
gem "faker"
gem "will_paginate"
gem "bootstrap-will_paginate"

group :development, :test do
  gem "sqlite3"
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "pry-rails"
end

group :development do
  gem "rubocop"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "rails-controller-testing"
  gem "minitest"
  gem "minitest-reporters"
  gem "guard"
  gem "guard-minitest"
end

group :production do
  gem "pg"
end
