# frozen_string_literal: true

module Constants
  INFLECTIONS = {
    "otp_service" => "OTPService",
    "api" => "API",
    "sms" => "SMS"
  }.freeze

  DIRS_TO_LOAD = %w[lib].freeze
  DIRS_TO_RELOAD = %w[lib config].freeze

  USER_API = "user"
  USER_PUBLIC_ROUTES = Hanami::Router.new do
    get "/v1/users", to: ->(_) {}
  end.freeze
end
