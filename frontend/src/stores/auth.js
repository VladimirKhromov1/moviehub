import { defineStore } from 'pinia'
import api from '@/services/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isAuthenticated: false,
    loading: false
  }),

  actions: {
    async register(email, password, passwordConfirmation) {
      this.loading = true
      try {
        const response = await api.post('/auth/register', {
          email,
          password,
          password_confirmation: passwordConfirmation
        })
        this.user = response.data.user
        this.isAuthenticated = true
        return { success: true }
      } catch (error) {
        return {
          success: false,
          errors: error.response?.data?.errors || ['Registration failed']
        }
      } finally {
        this.loading = false
      }
    },

    async login(email, password) {
      this.loading = true
      try {
        const response = await api.post('/auth/login', { email, password })
        this.user = response.data.user
        this.isAuthenticated = true
        return { success: true }
      } catch (error) {
        return {
          success: false,
          error: error.response?.data?.error || 'Login failed'
        }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      try {
        await api.delete('/auth/logout')
      } finally {
        this.user = null
        this.isAuthenticated = false
      }
    },

    async checkAuth() {
      try {
        const response = await api.get('/auth/me')
        this.user = response.data.user
        this.isAuthenticated = true
      } catch (error) {
        this.user = null
        this.isAuthenticated = false
      }
    }
  }
})
