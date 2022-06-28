# frozen_string_literal: true

require "sinatra/base"

class Cerberus < Sinatra::Base
  require_relative "config/application"

  before do
    @processing_started = Time.now
    content_type :json
    @client_request = ClientRequest.new(
      path: request.path,
      verb: request.request_method,
      params: request.params
    )
    decode_jwt_token
  end

  after { log_response }

  %i[get post patch put delete].each do |method_name|
    method(method_name).call("/v1/users", "/v1/users/*") do
      api_response = Dispatcher.new(client_request: @client_request).dispatch
      [api_response.status, api_response.body]
    end
  end
<<<<<<< Updated upstream
end
=======
>>>>>>> Stashed changes

  post "/v1/auth/otp/code" do
    otp_service = Auth::OTPService.new(client_request: @client_request)
    ElasticAPM.report_message('This should probably never happen?!')
    if otp_service.call
      status otp_service.status
      json otp_service.payload
    else
      status 404
      json errors: { messages: ["user not found"] }
    end
  end

  post "/v1/auth/otp/verify" do
    auth_service = AuthService.new(client_request: @client_request)
    auth_service.call

    if auth_service.token
      json data: [jwt: auth_service.token]
    else
      status 401
      json message: "not correct code or user"
    end
  end

  get "/", "/health_check" do
    json status: "ok"
  end

  error do
    case env["sinatra.error"]
    when Errors::Authentication
      status 401
      json_response = { errors: { messages: ["Sorry, you need to authenticate first"] } }
    else
      status 500
      json_response = { errors: { messages: ["Sorry, server error occurred. Please, try again later"] } }
    end

    json_response.merge!(debug_info) if ENV["APP_ENV"].eql?("development")
    json json_response
  end

  error 404 do
    status 404
    json errors: { messages: ["Sorry entity you requested not found"] }
  end

  def debug_info
    {
      debug: {
        exception_name: env["sinatra.error"].class,
        exception_message: env["sinatra.error"]&.message,
        request_params: params,
        stack_trace: env["sinatra.error"]&.backtrace
      }
    }
  end

  def decode_jwt_token
    return if env["HTTP_AUTHORIZATION"].blank?

    token = env["HTTP_AUTHORIZATION"].split[1]
    return if token.blank?

    RequestStore.store[:jwt_payload] = JWT.decode(token, ENV.fetch("AUTH_HMAC_SECRET"), nil, { algorithm: "HS256" })
  end

  def skip_logging?
    return true if env["sinatra.error"] && development?

    request.path == "/health_check" || request.path == "/"
  end

  def log_response
    return if skip_logging?

    log_params = {
      path: request.path,
      params: request.params,
      ip_address: request.ip,
      duration: ((Time.now - @processing_started) * 1_000).round(2),
      http: {
        method: request.request_method,
        status_code: response.status
      }
    }

    case log_params[:http][:status_code]
    when 0..399
      logger.info(log_params.merge(level: "INFO"))
    else
      error_params = {
        level: "ERROR",
        exception_name: env["sinatra.error"].class,
        exception_message: env["sinatra.error"]&.message,
        stack_trace: env["sinatra.error"]&.backtrace&.join("\n")
      }
      logger.info(log_params.merge(error_params))
    end
  end

  run! if app_file == $0
end
