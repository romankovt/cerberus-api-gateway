# frozen_string_literal: true

ENV["APP_ENV"] ||= "development" # <env>

require "bundler"
require "yaml"

# <boot>
Bundler.require(:default, ENV.fetch("APP_ENV", nil))
require "sinatra/reloader" if development?
require "dotenv/load" if development? || test?
require "zeitwerk"

loader = Zeitwerk::Registry.loaders[0] || Zeitwerk::Loader.new
# add dirs to track on top level for zeitwerk
dira_to_load = %w[services].freeze
dira_to_load.each do |dir_name|
  dir_path = File.join(Dir.pwd, "app", dir_name)
  loader.push_dir(dir_path) if !loader.dirs.include?(dir_path)
end

# reloading custom files and dirs
dirs_to_reload = ["app", "config"]
dirs_to_reload.each do |dir|
  also_reload "#{dir}/**/*.rb"
end
dont_reload "config/puma.rb" # puma is pointless to reload, you need a server restart

# ignore puma in zeitwerk, it's loaded by puma automatically
loader.ignore("#{__dir__}/puma.rb")
loader.setup # ready!

# </boot>

# load modules which need to be loaded manually
# require_relative "constants"

# modules from sinatra-contrib
require "sinatra/json"
require "sinatra/multi_route"
require "sinatra/custom_logger"

# remove default logger
set :logging, nil

# set our custom logging
require_relative "logging"

loader.eager_load if production? || test?

# configure Oj for faster working with json
Oj.mimic_JSON
Oj.add_to_json # monkey patch all known #to_json methods

class Application
  class << self
    extend Memoist
  end
end
