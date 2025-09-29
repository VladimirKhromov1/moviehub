# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::AuthController', type: :request do
  let(:valid_user_params) do
    {
      email: 'test@example.com',
      password: 'password123',
      password_confirmation: 'password123'
    }
  end

  describe 'POST /api/v1/auth/register' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v1/auth/register', params: valid_user_params
        }.to change(User, :count).by(1)
      end

      it 'returns success response' do
        post '/api/v1/auth/register', params: valid_user_params

        expect(response).to have_http_status(:created)
        expect(json_response[:message]).to eq('User created successfully')
      end

      it 'returns user data' do
        post '/api/v1/auth/register', params: valid_user_params

        expect(json_response[:user]).to include(
          id: be_present,
          email: 'test@example.com',
          default_lists: [ 'Want to Watch', 'Favorites' ]
        )
      end

      it 'sets authentication cookie' do
        post '/api/v1/auth/register', params: valid_user_params

        expect(response.cookies['auth_token']).to be_present
      end

      it 'creates default lists for user' do
        post '/api/v1/auth/register', params: valid_user_params

        user = User.find_by(email: 'test@example.com')
        expect(user.user_lists.count).to eq(2)
        expect(user.user_lists.pluck(:name)).to include('Want to Watch', 'Favorites')
      end
    end

    context 'with invalid parameters' do
      it 'returns error for missing email' do
        post '/api/v1/auth/register', params: valid_user_params.except(:email)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include("Email can't be blank")
      end

      it 'returns error for invalid email format' do
        post '/api/v1/auth/register', params: valid_user_params.merge(email: 'invalid-email')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Email is invalid')
      end

      it 'returns error for short password' do
        post '/api/v1/auth/register', params: valid_user_params.merge(password: '123')

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Password is too short (minimum is 6 characters)')
      end

      it 'returns error for duplicate email' do
        create(:user, email: 'test@example.com')
        post '/api/v1/auth/register', params: valid_user_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to include('Email has already been taken')
      end

      it 'does not create user with invalid data' do
        expect {
          post '/api/v1/auth/register', params: valid_user_params.merge(email: 'invalid')
        }.not_to change(User, :count)
      end
    end
  end

  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns success response' do
        post '/api/v1/auth/login', params: { email: 'test@example.com', password: 'password123' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Login successful')
      end

      it 'returns user data' do
        post '/api/v1/auth/login', params: { email: 'test@example.com', password: 'password123' }

        expect(json_response[:user]).to include(
          id: user.id,
          email: 'test@example.com'
        )
      end

      it 'sets authentication cookie' do
        post '/api/v1/auth/login', params: { email: 'test@example.com', password: 'password123' }

        expect(response.cookies['auth_token']).to be_present
      end

      it 'handles case insensitive email' do
        post '/api/v1/auth/login', params: { email: 'TEST@EXAMPLE.COM', password: 'password123' }

        expect(response).to have_http_status(:ok)
        expect(json_response[:user][:email]).to eq('test@example.com')
      end
    end

    context 'with invalid credentials' do
      it 'returns error for wrong password' do
        post '/api/v1/auth/login', params: { email: 'test@example.com', password: 'wrongpassword' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Invalid email or password')
      end

      it 'returns error for non-existent email' do
        post '/api/v1/auth/login', params: { email: 'nonexistent@example.com', password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Invalid email or password')
      end

      it 'returns error for missing email' do
        post '/api/v1/auth/login', params: { password: 'password123' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Invalid email or password')
      end

      it 'returns error for missing password' do
        post '/api/v1/auth/login', params: { email: 'test@example.com' }

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Invalid email or password')
      end

      it 'does not set authentication cookie' do
        post '/api/v1/auth/login', params: { email: 'test@example.com', password: 'wrongpassword' }

        expect(response.cookies['auth_token']).to be_blank
      end
    end
  end

  describe 'DELETE /api/v1/auth/logout' do
    let(:user) { create(:user) }

    context 'when user is authenticated' do
      before do
        set_auth_cookie_for(user)
      end

      it 'returns success response' do
        delete '/api/v1/auth/logout'

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Logout successful')
      end

      it 'clears authentication cookie' do
        delete '/api/v1/auth/logout'

        expect(response.cookies['auth_token']).to be_blank
      end
    end

    context 'when user is not authenticated' do
      it 'still returns success response' do
        delete '/api/v1/auth/logout'

        expect(response).to have_http_status(:ok)
        expect(json_response[:message]).to eq('Logout successful')
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let(:user) { create(:user, email: 'current@example.com') }

    context 'when user is authenticated' do
      before do
        set_auth_cookie_for(user)
      end

      it 'returns user data' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:ok)
        expect(json_response[:user]).to include(
          id: user.id,
          email: 'current@example.com'
        )
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not authenticated')
      end
    end

    context 'when token is invalid' do
      before do
        key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
        secret = key_generator.generate_key('signed cookie')
        verifier = ActiveSupport::MessageVerifier.new(secret)
        signed_token = verifier.generate('invalid_token')
        cookies[:auth_token] = signed_token
      end

      it 'returns unauthorized error' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not authenticated')
      end
    end

    context 'when token is expired' do
      before do
        expired_token = JwtService.encode({ user_id: user.id }, 1.hour.ago)
        key_generator = ActiveSupport::KeyGenerator.new(Rails.application.secret_key_base)
        secret = key_generator.generate_key('signed cookie')
        verifier = ActiveSupport::MessageVerifier.new(secret)
        signed_token = verifier.generate(expired_token)
        cookies[:auth_token] = signed_token
      end

      it 'returns unauthorized error' do
        get '/api/v1/auth/me'

        expect(response).to have_http_status(:unauthorized)
        expect(json_response[:error]).to eq('Not authenticated')
      end
    end
  end
end
