# frozen_string_literal: true

class Dispatcher
  attr_reader :client_request, :path, :params, :verb

  def initialize(client_request:)
    @client_request = client_request
    @path = client_request.path
    @params = client_request.params
    @verb = client_request.verb
  end

  def dispatch
    case client_request.api_service
    when "user"
      User::Authentication.new(client_request:).auth!
      User::Dispatcher.new(path:, params:, verb:).dispatch
    end
  end
end
