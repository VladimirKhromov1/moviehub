import { createPinia, setActivePinia } from 'pinia'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

// Mock the API module
jest.mock('@/services/api')

describe('Auth Store', () => {
  let store
  
  beforeEach(() => {
    setActivePinia(createPinia())
    store = useAuthStore()
    jest.clearAllMocks()
  })

  describe('initial state', () => {
    it('should have correct initial state', () => {
      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
      expect(store.loading).toBe(false)
    })
  })

  describe('register action', () => {
    const mockUser = { id: 1, email: 'test@example.com' }
    const registerData = {
      email: 'test@example.com',
      password: 'password123',
      passwordConfirmation: 'password123'
    }

    it('should register user successfully', async () => {
      const mockResponse = { data: { user: mockUser } }
      api.post.mockResolvedValue(mockResponse)

      const result = await store.register(
        registerData.email,
        registerData.password,
        registerData.passwordConfirmation
      )

      expect(api.post).toHaveBeenCalledWith('/auth/register', {
        email: 'test@example.com',
        password: 'password123',
        password_confirmation: 'password123'
      })
      expect(store.user).toEqual(mockUser)
      expect(store.isAuthenticated).toBe(true)
      expect(store.loading).toBe(false)
      expect(result).toEqual({ success: true })
    })

    it('should handle registration failure', async () => {
      const mockError = {
        response: { data: { errors: ['Email is already taken'] } }
      }
      api.post.mockRejectedValue(mockError)

      const result = await store.register(
        registerData.email,
        registerData.password,
        registerData.passwordConfirmation
      )

      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
      expect(store.loading).toBe(false)
      expect(result).toEqual({
        success: false,
        errors: ['Email is already taken']
      })
    })

    it('should handle registration failure without specific errors', async () => {
      const mockError = { response: null }
      api.post.mockRejectedValue(mockError)

      const result = await store.register(
        registerData.email,
        registerData.password,
        registerData.passwordConfirmation
      )

      expect(result).toEqual({
        success: false,
        errors: ['Registration failed']
      })
    })

    it('should set loading state during registration', async () => {
      const mockResponse = { data: { user: mockUser } }
      api.post.mockImplementation(() => {
        expect(store.loading).toBe(true)
        return Promise.resolve(mockResponse)
      })

      await store.register(
        registerData.email,
        registerData.password,
        registerData.passwordConfirmation
      )

      expect(store.loading).toBe(false)
    })
  })

  describe('login action', () => {
    const mockUser = { id: 1, email: 'test@example.com' }
    const loginData = { email: 'test@example.com', password: 'password123' }

    it('should login user successfully', async () => {
      const mockResponse = { data: { user: mockUser } }
      api.post.mockResolvedValue(mockResponse)

      const result = await store.login(loginData.email, loginData.password)

      expect(api.post).toHaveBeenCalledWith('/auth/login', {
        email: 'test@example.com',
        password: 'password123'
      })
      expect(store.user).toEqual(mockUser)
      expect(store.isAuthenticated).toBe(true)
      expect(store.loading).toBe(false)
      expect(result).toEqual({ success: true })
    })

    it('should handle login failure', async () => {
      const mockError = {
        response: { data: { error: 'Invalid credentials' } }
      }
      api.post.mockRejectedValue(mockError)

      const result = await store.login(loginData.email, loginData.password)

      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
      expect(store.loading).toBe(false)
      expect(result).toEqual({
        success: false,
        error: 'Invalid credentials'
      })
    })

    it('should handle login failure without specific error', async () => {
      const mockError = { response: null }
      api.post.mockRejectedValue(mockError)

      const result = await store.login(loginData.email, loginData.password)

      expect(result).toEqual({
        success: false,
        error: 'Login failed'
      })
    })

    it('should set loading state during login', async () => {
      const mockResponse = { data: { user: mockUser } }
      api.post.mockImplementation(() => {
        expect(store.loading).toBe(true)
        return Promise.resolve(mockResponse)
      })

      await store.login(loginData.email, loginData.password)

      expect(store.loading).toBe(false)
    })
  })

  describe('logout action', () => {
    beforeEach(() => {
      // Set authenticated state
      store.user = { id: 1, email: 'test@example.com' }
      store.isAuthenticated = true
    })

    it('should logout user successfully', async () => {
      api.delete.mockResolvedValue({})

      await store.logout()

      expect(api.delete).toHaveBeenCalledWith('/auth/logout')
      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
    })

    it('should clear user state even if logout request fails', async () => {
      const mockError = new Error('Network error')
      api.delete.mockRejectedValue(mockError)

      // Logout will throw error but still clear user state
      await expect(store.logout()).rejects.toThrow('Network error')

      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
    })
  })

  describe('checkAuth action', () => {
    const mockUser = { id: 1, email: 'test@example.com' }

    it('should set user when authenticated', async () => {
      const mockResponse = { data: { user: mockUser } }
      api.get.mockResolvedValue(mockResponse)

      await store.checkAuth()

      expect(api.get).toHaveBeenCalledWith('/auth/me')
      expect(store.user).toEqual(mockUser)
      expect(store.isAuthenticated).toBe(true)
    })

    it('should clear user when not authenticated', async () => {
      // Set initial authenticated state
      store.user = mockUser
      store.isAuthenticated = true
      
      const mockError = { response: { status: 401 } }
      api.get.mockRejectedValue(mockError)

      await store.checkAuth()

      expect(store.user).toBeNull()
      expect(store.isAuthenticated).toBe(false)
    })
  })
})
