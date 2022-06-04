# frozen_string_literal: true

require "logger"

logger = Logger.new($stdout)

logger.level =
  if test?
    Logger::WARN
  elsif production?
    Logger::INFO
  else
    Logger::DEBUG
  end

logger.formatter = proc do |severity, datetime, _progname, msg|
  shared_info = { type: severity, time: datetime&.to_s }

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

  if production?
    JSON.dump((log_entry.end_with?("\n") ? log_entry : "#{log_entry}\n"))
  else
    ap(log_entry)
    puts "---------"
  end
end

set :logger, logger
