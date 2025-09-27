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

  def current_user
    return @current_user if defined?(@current_user)

    token = current_user_token
    return nil unless token

    decoded_token = JwtService.decode(token)
    @current_user = decoded_token ? User.find_by(id: decoded_token[:user_id]) : nil
  end

  def require_authentication
    unless current_user
      render json: { error: 'Authentication required' }, status: :unauthorized
    end
  end

  def user_authenticated?
    current_user.present?
  end
end