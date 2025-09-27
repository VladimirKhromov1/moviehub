class Api::V1::AuthController < Api::V1::BaseController
  def register
    user = User.new(user_params)

    if user.save
      token = JwtService.encode(user_id: user.id)
      set_auth_cookie(token)

      render json: {
        message: 'User created successfully',
        user: {
          id: user.id,
          email: user.email,
          default_lists: user.user_lists.pluck(:name)
        }
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)
      set_auth_cookie(token)

      render json: {
        message: 'Login successful',
        user: { id: user.id, email: user.email }
      }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def logout
    clear_auth_cookie
    render json: { message: 'Logout successful' }
  end

  def me
    if current_user
      render json: { user: { id: current_user.id, email: current_user.email } }
    else
      render json: { error: 'Not authenticated' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

end