import { defineStore } from 'pinia'
import api from '@/services/api'

export const useMoviesStore = defineStore('movies', {
  state: () => ({
    movies: [],
    bestFilms: [],
    genres: [],

    pagination: null,
    bestFilmsPagination: null,

    loading: false,
    bestFilmsLoading: false,
    genresLoading: false,
    error: null,

    filters: {
      search: '',
      genres: [],
      min_rating: null,
      year: null,
      sort_by: 'created_at'
    }
  }),

  getters: {
    hasActiveFilters: (state) => {
      return !!(
        state.filters.search?.trim() ||
        state.filters.genres?.length > 0 ||
        state.filters.min_rating ||
        state.filters.year ||
        (state.filters.sort_by && state.filters.sort_by !== 'created_at')
      )
    },

    genreOptions: (state) => {
      return state.genres.map(genre => ({
        value: genre.name,
        label: `${genre.name} (${genre.movies_count})`
      }))
    }
  },

  actions: {
    async fetchMovies(page = 1, perPage = 20, customFilters = null) {
      const isFiltering = !!customFilters

      if (!isFiltering) {
        this.loading = true
      }
      this.error = null

      try {
        const filters = customFilters || this.filters
        const params = this._buildApiParams(page, perPage, filters)

        const response = await api.get('/movies', { params })

        this.movies = response.data.movies
        this.pagination = response.data.pagination

        if (customFilters) {
          this.filters = { ...this.filters, ...customFilters }
        }
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

    async fetchGenres() {
      if (this.genres.length > 0) return

      this.genresLoading = true
      try {
        const response = await api.get('/movies/genres')
        this.genres = response.data.genres
      } catch (error) {
        console.error('Genres fetch error:', error)
      } finally {
        this.genresLoading = false
      }
    },

    async applyFilters(filters) {
      this.filters = { ...filters }
      await this.fetchMovies(1, 20, filters)
    },

    async toggleLike(movieId) {
      try {
        const movie = this._findMovie(movieId)
        if (!movie) return

        let response
        if (movie.liked_by_current_user) {
          response = await api.delete(`/movies/${movieId}/like`)
        } else {
          response = await api.post(`/movies/${movieId}/like`)
        }

        this._updateMovieLike(movieId, {
          liked: response.data.liked,
          likesCount: response.data.likes_count
        })

        return response.data
      } catch (error) {
        console.error('Like toggle error:', error)
        throw error
      }
    },

    _buildApiParams(page, perPage, filters) {
      const params = {
        page,
        per_page: perPage
      }

      if (filters.search?.trim()) {
        params.search = filters.search.trim()
      }

      if (filters.genres?.length > 0) {
        params.genres = filters.genres.join(',')
      }

      if (filters.min_rating) {
        params.min_rating = filters.min_rating
      }

      if (filters.year) {
        params.year = filters.year
      }

      if (filters.sort_by && filters.sort_by !== 'created_at') {
        params.sort_by = filters.sort_by
      }

      return params
    },

    _findMovie(movieId) {
      return this.movies.find(m => m.id === movieId) ||
             this.bestFilms.find(m => m.id === movieId)
    },

    _updateMovieLike(movieId, { liked, likesCount }) {
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
