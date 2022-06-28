# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.1.2"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "sinatra", "~> 2.2.0"
gem "sinatra-contrib", "~> 2.2.0"
gem "puma", "~> 5.6.4"
gem "oj", "~> 3.13.13"
gem "awesome_print", "~> 1.9.2"
gem "memoist", "~> 0.16.2"
gem "faraday", "~> 2.3.0"
gem "pp", "~> 0.3.0"
gem "zeitwerk", "~> 2.5.4"
gem "jwt", "~> 2.4.1"
gem "request_store", "~> 1.5.1"
gem "activesupport", "~> 7.0.3"
gem "hanami-router", "~> 2.0.0.alpha6"
gem "elastic-apm", "~> 4.5.1"

group :development do
  gem "rubocop", "~> 1.30.0", require: false
  gem "rubocop-performance", "~> 1.14.0", require: false
  gem "dotenv", "~> 2.7.6"
end

group :development, :test do
  gem "pry-byebug", "~> 3.9.0"
end
