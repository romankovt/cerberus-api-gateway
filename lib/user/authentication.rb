# frozen_string_literal: true

class User::Authentication < BaseService
  attr_reader :path, :verb

  def initialize(client_request:)
    @path = client_request.path
    @verb = client_request.verb
  end

  def auth!
    return true if public_route?
    raise Errors::Authentication, "auth required" unless valid_jwt_payload?

    true
  end

  private

  def public_route?
    Constants::USER_PUBLIC_ROUTES.recognize(path, {}, method: verb).routable?
  end

  def valid_jwt_payload?
    return false if RequestStore[:jwt_payload].blank?
    return false if RequestStore[:jwt_payload][0].blank?
    return false if RequestStore[:jwt_payload][0]["id"].blank?
    return false if RequestStore[:jwt_payload][0]["api_user_class"] != Constants::USER_API

    true
  end
end
