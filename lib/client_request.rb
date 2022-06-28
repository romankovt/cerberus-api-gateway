# frozen_string_literal: true

class ClientRequest
  attr_reader :path, :verb, :params

  def initialize(path:, verb:, params: {})
    @path = path
    @verb = verb
    @params = params
  end

  def api_service
    Constants::USER_API if @path.start_with?("/v1/users")
  end
end
