# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JwtService, type: :service do
  describe '.encode' do
    let(:payload) { { user_id: 123, email: 'test@example.com' } }
    let(:custom_exp) { 2.hours.from_now }

    it 'encodes payload with default expiration' do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').length).to eq(3) # JWT has 3 parts
    end

    it 'encodes payload with custom expiration' do
      token = JwtService.encode(payload, custom_exp)
      decoded = JwtService.decode(token)

      expect(decoded[:exp]).to eq(custom_exp.to_i)
    end

    it 'includes expiration in the payload' do
      freeze_time do
        token = JwtService.encode(payload)
        decoded = JwtService.decode(token)

        expect(decoded[:exp]).to eq(24.hours.from_now.to_i)
      end
    end

    it 'preserves original payload data' do
      token = JwtService.encode(payload)
      decoded = JwtService.decode(token)

      expect(decoded[:user_id]).to eq(123)
      expect(decoded[:email]).to eq('test@example.com')
    end
  end

  describe '.decode' do
    let(:payload) { { user_id: 456, role: 'admin' } }

    context 'with valid token' do
      let(:token) { JwtService.encode(payload) }

      it 'decodes token successfully' do
        decoded = JwtService.decode(token)

        expect(decoded).to be_a(HashWithIndifferentAccess)
        expect(decoded[:user_id]).to eq(456)
        expect(decoded[:role]).to eq('admin')
      end

      it 'includes expiration time' do
        decoded = JwtService.decode(token)
        expect(decoded[:exp]).to be_present
        expect(decoded[:exp]).to be_a(Integer)
      end
    end

    context 'with invalid token' do
      it 'returns nil for malformed token' do
        invalid_token = 'invalid.token.here'
        expect(JwtService.decode(invalid_token)).to be_nil
      end

      it 'returns nil for token with wrong signature' do
        # Create token with different secret
        wrong_token = JWT.encode(payload, 'wrong_secret')
        expect(JwtService.decode(wrong_token)).to be_nil
      end

      it 'returns nil for expired token' do
        expired_token = JwtService.encode(payload, 1.hour.ago)
        expect(JwtService.decode(expired_token)).to be_nil
      end

      it 'returns nil for nil token' do
        expect(JwtService.decode(nil)).to be_nil
      end

      it 'returns nil for empty token' do
        expect(JwtService.decode('')).to be_nil
      end
    end

    context 'error handling' do
      it 'handles JWT::DecodeError gracefully' do
        allow(JWT).to receive(:decode).and_raise(JWT::DecodeError.new('Test error'))

        result = JwtService.decode('any_token')
        expect(result).to be_nil
      end

      it 'handles JWT::ExpiredSignature gracefully' do
        allow(JWT).to receive(:decode).and_raise(JWT::ExpiredSignature.new('Token expired'))

        result = JwtService.decode('expired_token')
        expect(result).to be_nil
      end
    end
  end

  describe 'SECRET_KEY' do
    it 'uses Rails secret key base' do
      expect(JwtService::SECRET_KEY).to eq(Rails.application.credentials.secret_key_base)
    end
  end

  describe 'round trip encoding/decoding' do
    let(:original_payload) { { user_id: 789, email: 'roundtrip@example.com', admin: true } }

    it 'maintains data integrity through encode/decode cycle' do
      token = JwtService.encode(original_payload)
      decoded = JwtService.decode(token)

      expect(decoded[:user_id]).to eq(original_payload[:user_id])
      expect(decoded[:email]).to eq(original_payload[:email])
      expect(decoded[:admin]).to eq(original_payload[:admin])
    end

    it 'adds expiration that can be verified' do
      freeze_time do
        expected_exp = 24.hours.from_now.to_i
        token = JwtService.encode(original_payload)
        decoded = JwtService.decode(token)

        expect(decoded[:exp]).to eq(expected_exp)
      end
    end
  end

  describe 'token format validation' do
    let(:payload) { { user_id: 1 } }

    it 'creates JWT with proper structure' do
      token = JwtService.encode(payload)
      parts = token.split('.')

      expect(parts.length).to eq(3)
      expect(parts[0]).to match(/^[A-Za-z0-9_-]+$/) # Header
      expect(parts[1]).to match(/^[A-Za-z0-9_-]+$/) # Payload
      expect(parts[2]).to match(/^[A-Za-z0-9_-]+$/) # Signature
    end
  end
end
