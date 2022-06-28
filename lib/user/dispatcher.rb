# frozen_string_literal: true

class User::Dispatcher < BaseService
  HOST = ENV.fetch("USER_API_HOST", "localhost")
  PORT = ENV.fetch("USER_API_PORT", "3000")

  attr_reader :url, :request, :response

  def initialize(path:, verb:, params:)
    @path = path
    @verb = verb
    @params = params
    @url = URI::HTTP.build(host: HOST, port: PORT, path:)
  end

  def dispatch
    dispatcher = RequestDispatcher.new(url: @url, verb: @verb, params: @params)
    @response = dispatcher.call
  end

  def json
    @json ||= JSON.parse(response.body)
  end
end
