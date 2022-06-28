# frozen_string_literal: true

class Cerberus
  require "logger"
  require "sinatra/custom_logger"

  helpers Sinatra::CustomLogger

  class MultiDelegator
    def initialize(*targets)
      @targets = targets
    end

    def self.delegate(*methods)
      methods.each do |m|
        define_method(m) do |*args|
          @targets.map { |t| t.send(m, *args) }
        end
      end
      self
    end

    class << self
      alias_method :to, :new
    end
  end

  file = File.open("#{root}/logs/#{environment}.log", "a")
  file.sync = true
  custom_logger = Logger.new(MultiDelegator.delegate(:write, :close).to(file, $stdout))

  custom_logger.level =
    if test?
      Logger::WARN
    elsif production?
      Logger::INFO
    else
      Logger::DEBUG
    end

  custom_logger.formatter = proc do |severity, datetime, _progname, msg|
    shared_info = { type: severity, time: datetime&.iso8601 }

    log_entry =
      case msg
      when String
        # enrich string messages with additional info
        shared_info.merge(message: msg)
      when Hash
        # enrich structured messages with additional info
        msg.merge(shared_info)
      else
        # just dump 'as is'
        msg
      end

    # json_log = production? ? JSON.dump(log_entry) : JSON.pretty_generate(log_entry)
    json_log = JSON.dump(log_entry)
    json_log.end_with?("\n") ? json_log : "#{json_log}\n"
  end

  set :logger, custom_logger
end
