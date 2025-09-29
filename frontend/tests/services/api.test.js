// Mock axios
jest.mock('axios', () => ({
  create: jest.fn(() => ({
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
  }))
}))

import axios from 'axios'

describe('API Service', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should create axios instance with correct configuration', () => {
    // Import API service to trigger axios.create call
    require('@/services/api')
    
    expect(axios.create).toHaveBeenCalledWith({
      baseURL: '/api/v1',
      headers: {
        'Content-Type': 'application/json'
      },
      withCredentials: true
    })
  })

  it('should export the configured axios instance', () => {
    const api = require('@/services/api').default
    expect(api).toBeDefined()
  })
})
