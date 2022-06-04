class RequestDispatcher
  attr_reader :url, :verb, :params, :response

  TIMEOUT = 60
  OPEN_TIMEOUT = 3

  def initialize(url:, verb:, params:)
    @url = url
    @verb = verb
    @params = params
    @conn = Faraday.new(
      headers: { "Content-Type": "application/json" },
      request: { timeout: TIMEOUT, open_timeout: OPEN_TIMEOUT }
    )
  end

  def call
    response =
      case @verb
      when "GET"
        @conn.get(@url, @params)
      when "POST"
        @conn.post(@url) do |req|
          req.body = @params.to_json if @params
        end
      when "PATCH"
        @conn.patch(@url, @params) do |req|
          req.body = @params.to_json if @params
        end
      when "PUT"
        @conn.put(@url, @params) do |req|
          req.body = @params.to_json if @params
        end
      when "DELETE"
        @conn.delete(@url, @params) do |req|
          req.body = @params.to_json if @params
        end
      else
        puts "unsupported HTTP verb"
      end
    @response = response
  end
end
