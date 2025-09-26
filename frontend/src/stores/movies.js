import { defineStore } from 'pinia'
import api from '@/services/api'

export const useMoviesStore = defineStore('movies', {
  state: () => ({
    movies: [],
    pagination: null,
    loading: false,
    error: null
  }),

  actions: {
    async fetchMovies(page = 1, perPage = 20) {
      this.loading = true
      this.error = null

      try {
        const response = await api.get('/movies', {
          params: { page, per_page: perPage }
        })

        this.movies = response.data.movies
        this.pagination = response.data.pagination
      } catch (error) {
        this.error = 'Failed to load movies'
        console.error('Movies fetch error:', error)
      } finally {
        this.loading = false
      }
    }
  }
})
