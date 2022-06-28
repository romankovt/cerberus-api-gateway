# frozen_string_literal: true

class Auth::OTPService < BaseService
  attr_reader :params, :status, :payload

  def initialize(client_request:)
    @request = client_request
    @params = client_request.params
  end

  def call
    @payload =
      case params["user_class"]
      when "User"
        { phone: params["phone"], code: }
      else
        { phone: nil, code: nil }
      end
    @status = @payload[:code].blank? ? 422 : 200
    [@status, @payload]
  end

  private

  def code
    "11-11-11"
  end
end
