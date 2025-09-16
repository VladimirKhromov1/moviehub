class Api::V1::BaseController < ApplicationController
  include ActionController::Cookies

  private

  def set_auth_cookie(token)
    cookies.signed[:auth_token] = {
      value: token,
      httponly: true,
      secure: Rails.env.production?,
      same_site: :lax,
      expires: 24.hours.from_now
    }
  end

  def current_user_token
    cookies.signed[:auth_token]
  end

  def clear_auth_cookie
    cookies.delete(:auth_token)
  end
end