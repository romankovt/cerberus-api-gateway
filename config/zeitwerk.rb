# frozen_string_literal: true

class Cerberus
  require "sinatra/reloader" if development?

  configure :development do
    register Sinatra::Reloader
  end

  loader = Zeitwerk::Registry.loaders[0] || Zeitwerk::Loader.new
  # add dirs to track on top level for zeitwerk
  dira_to_load = Constants::DIRS_TO_LOAD.freeze
  dira_to_load.each do |dir_name|
    dir_path = File.join(Dir.pwd, dir_name)
    loader.push_dir(dir_path) unless loader.dirs.include?(dir_path)
  end
  loader.inflector.inflect(Constants::INFLECTIONS)
  # reloading custom files and dirs
  dirs_to_reload = Constants::DIRS_TO_RELOAD
  dirs_to_reload.each do |dir|
    also_reload "#{dir}/**/*.rb"
  end

  dont_reload "config/puma.rb" # puma is pointless to reload, you need a server restart
  # ignore puma in zeitwerk, it's loaded by puma automatically
  loader.ignore("#{__dir__}/puma.rb")
  loader.setup # ready!

  loader.eager_load if Cerberus.production? || Cerberus.test?
end
