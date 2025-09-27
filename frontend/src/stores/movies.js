import { defineStore } from 'pinia'
import api from '@/services/api'

export const useMoviesStore = defineStore('movies', {
  state: () => ({
    movies: [],
    bestFilms: [],
    pagination: null,
    bestFilmsPagination: null,
    loading: false,
    bestFilmsLoading: false,
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
    },

    async fetchBestFilms(page = 1, perPage = 20) {
      this.bestFilmsLoading = true
      this.error = null

      try {
        const response = await api.get('/movies/best_films', {
          params: { page, per_page: perPage }
        })

        this.bestFilms = response.data.movies
        this.bestFilmsPagination = response.data.pagination
      } catch (error) {
        this.error = 'Failed to load best films'
        console.error('Best films fetch error:', error)
      } finally {
        this.bestFilmsLoading = false
      }
    },

    async toggleLike(movieId) {
      try {
        const movie = this.findMovie(movieId)
        if (!movie) return

        let response
        if (movie.liked_by_current_user) {
          response = await api.delete(`/movies/${movieId}/like`)
        } else {
          response = await api.post(`/movies/${movieId}/like`)
        }

        this.updateMovieLike(movieId, {
          liked: response.data.liked,
          likesCount: response.data.likes_count
        })

        return response.data
      } catch (error) {
        console.error('Like toggle error:', error)
        throw error
      }
    },

    findMovie(movieId) {
      return this.movies.find(m => m.id === movieId) ||
        this.bestFilms.find(m => m.id === movieId)
    },

    updateMovieLike(movieId, { liked, likesCount }) {
      const movieIndex = this.movies.findIndex(m => m.id === movieId)
      if (movieIndex !== -1) {
        this.movies[movieIndex].liked_by_current_user = liked
        this.movies[movieIndex].likes_count = likesCount
      }

      const bestMovieIndex = this.bestFilms.findIndex(m => m.id === movieId)
      if (bestMovieIndex !== -1) {
        this.bestFilms[bestMovieIndex].liked_by_current_user = liked
        this.bestFilms[bestMovieIndex].likes_count = likesCount
      }
    }
  }
})
