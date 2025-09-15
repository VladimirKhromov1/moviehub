class Api::V1::HealthController < ApplicationController
  def index
    render json: {
      status: 'ok',
      timestamp: Time.current,
      version: '1.0.0'
    }
  end
end