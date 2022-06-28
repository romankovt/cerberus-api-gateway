# frozen_string_literal: true

class AuthService < BaseService
  attr_reader :request, :body, :status, :params, :token

  def initialize(client_request:)
    @request = client_request
    @params = client_request.params
  end

  def call
    raise StandardError if ENV["AUTH_HMAC_SECRET"].blank?

    user =
      case @params["api_user_class"]
      when "User"
        retrieve_user
      end

    return unless user

    payload = { id: @api_user["id"], api_user_class: @api_user["type"] }
    @token = JWT.encode(payload, ENV.fetch("AUTH_HMAC_SECRET"), "HS256")
  end

  private

  def retrieve_user
    service = User::Dispatcher.new(path: "/v1/users", params: { phones: @params["phone"] }, verb: "GET")
    service.dispatch

    return if service.json["data"].size != 1

    @api_user = service.json["data"][0]
  end
end
