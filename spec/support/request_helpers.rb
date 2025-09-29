# frozen_string_literal: true

module RequestHelpers
  def json_response
    @json_response ||= JSON.parse(response.body, symbolize_names: true)
  end

  def set_auth_cookie_for(user)
    # Patch the controller to return the user directly for tests
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end

  def auth_headers_for(user)
    token = JwtService.encode(user_id: user.id)
    key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
    secret = key_generator.generate_key('signed cookie')
    verifier = ActiveSupport::MessageVerifier.new(secret)
    signed_value = verifier.generate(token)
    { 'Cookie' => "auth_token=#{signed_value}" }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
