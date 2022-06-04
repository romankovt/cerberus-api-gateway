# frozen_string_literal: true

require_relative "config/application"

before do
  @processing_started = Time.now
  content_type :json
end

after { log_response }

[:get, :post, :patch, :put, :delete].each do |method_name|
  method(method_name).call("/v1/users", "/v1/users/*") do
    api_response = UserService.new(request: request).call
    [api_response.status, api_response.body]
  end
end
# post "/v1/users", "/v1/users/*" do
  # UserService.new(request: request).call
# end

get "/", "/health_check" do
  json status: "ok"
end

if production?
  error 500 do
    status 500
    json errors: { messages: ["Sorry, server error occured. Please, try again later"] }
  end

  error do
    status 500
    json errors: { messages: ["Sorry, server error occured. Please, try again later"] }
  end
end

error 404 do
  status 404
  json errors: { messages: ["Sorry entity you requested not found"] }
end

def skip_logging?
  # request.path == "/health_check" || request.path == "/"
end

def log_response
  return if skip_logging?

  log_params = {
    path: request.path,
    params: request.params,
    ip_address: request.ip,
    duration: ((Time.now - @processing_started) * 1_000).round(2),
    http: {
      method: request.env["REQUEST_METHOD"],
      status_code: response.status,
    },
  }

  case log_params[:http][:status_code]
  when 0..399
    logger.info(log_params.merge(level: "INFO"))
  else
    error_params = {
      level: "ERROR",
      exception_name: env["sinatra.error"].class,
      exception_message: env["sinatra.error"]&.message,
      stack_trace: env["sinatra.error"]&.backtrace&.join("\n"),
    }
    logger.info(log_params.merge(error_params))
  end
end
