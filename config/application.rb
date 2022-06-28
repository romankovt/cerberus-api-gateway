# frozen_string_literal: true

ENV["APP_ENV"] ||= "development" # <env>

require "bundler"
require "yaml"

# <boot>
Bundler.require(:default, ENV.fetch("APP_ENV", nil))

class Cerberus
  require "dotenv/load" if development? || test?
  require "zeitwerk"

  # load modules which need to be loaded manually
  require_relative "constants"

  # zitwerk config
  require_relative "zeitwerk"

  # modules from sinatra-contrib
  require "sinatra/json"
  require "sinatra/multi_route"
  require "active_support/all"

  # remove default logger
  # set :logging, nil
  # set our custom logging
  require_relative "logging"

  # configure Oj for faster working with json
  require_relative "oj"

  # down show default exceptions from sinatra
  set :show_exceptions, false

  # add request store
  use RequestStore::Middleware

  # enable contrib modules
  register Sinatra::MultiRoute

  # add elastic APM
  use ElasticAPM::Middleware
  ElasticAPM::Sinatra.start(Cerberus)

  at_exit { ElasticAPM.stop }

  # raise error if no jwt token
  raise StandardError, "no jwt token" if ENV.fetch("AUTH_HMAC_SECRET").blank?

  class << self
    extend Memoist
  end
end
