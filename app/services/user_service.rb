class UserService
  HOST = ENV.fetch("USER_API_HOST", "localhost")
  PORT = ENV.fetch("USER_API_PORT", "3000")

  attr_reader :url, :request

  def initialize(request:)
    @request = request
    @url = URI::HTTP.build(host: HOST, port: PORT, path: request.path)
  end

  def call
    dispatcher = RequestDispatcher.new(url: @url, verb: @request.request_method, params: @request.params)
    response = dispatcher.call
    response
  end
end
