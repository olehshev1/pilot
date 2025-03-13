source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.6"
gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "pg", "~> 1.1"
gem "dotenv-rails", ">= 3.1.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

group :development do
  gem "brakeman", "7.0.0"
  gem "bundler-audit", "0.9.2"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "fasterer", "0.11.0", require: false
  gem "overcommit", "0.67.1", require: false
  gem "rubocop", "1.71.2", require: false
  gem "rubocop-performance", "1.23.1"
  gem "rubocop-rspec", "3.4.0", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "rspec", "~> 3.10"
  gem "simplecov", "0.21.2", require: false
end

gem "bullet"
gem "rspec-rails", "~> 5.0"
gem "rubocop-rails"
gem "shoulda-matchers"
gem "database_consistency", require: false
gem "listen"
gem "factory_bot_rails"
gem "rails-controller-testing"
gem "rspec_junit_formatter"
