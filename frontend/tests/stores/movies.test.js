import { createPinia, setActivePinia } from 'pinia'
import { useMoviesStore } from '@/stores/movies'
import api from '@/services/api'

// Mock the API module
jest.mock('@/services/api')

describe('Movies Store', () => {
  let store
  
  beforeEach(() => {
    setActivePinia(createPinia())
    store = useMoviesStore()
    jest.clearAllMocks()
  })

  describe('initial state', () => {
    it('should have correct initial state', () => {
      expect(store.movies).toEqual([])
      expect(store.bestFilms).toEqual([])
      expect(store.genres).toEqual([])
      expect(store.pagination).toBeNull()
      expect(store.bestFilmsPagination).toBeNull()
      expect(store.loading).toBe(false)
      expect(store.bestFilmsLoading).toBe(false)
      expect(store.genresLoading).toBe(false)
      expect(store.error).toBeNull()
      expect(store.filters).toEqual({
        search: '',
        genres: [],
        min_rating: null,
        year: null,
        sort_by: 'created_at'
      })
    })
  })

  describe('getters', () => {
    describe('hasActiveFilters', () => {
      it('should return false when no filters are active', () => {
        expect(store.hasActiveFilters).toBe(false)
      })

      it('should return true when search filter is active', () => {
        store.filters.search = 'action'
        expect(store.hasActiveFilters).toBe(true)
      })

      it('should return true when genres filter is active', () => {
        store.filters.genres = ['Action']
        expect(store.hasActiveFilters).toBe(true)
      })

      it('should return true when min_rating filter is active', () => {
        store.filters.min_rating = 7.0
        expect(store.hasActiveFilters).toBe(true)
      })

      it('should return true when year filter is active', () => {
        store.filters.year = 2023
        expect(store.hasActiveFilters).toBe(true)
      })

      it('should return true when sort_by is not default', () => {
        store.filters.sort_by = 'rating'
        expect(store.hasActiveFilters).toBe(true)
      })
    })

    describe('genreOptions', () => {
      it('should transform genres into options format', () => {
        store.genres = [
          { name: 'Action', movies_count: 100 },
          { name: 'Comedy', movies_count: 75 }
        ]
        
        expect(store.genreOptions).toEqual([
          { value: 'Action', label: 'Action (100)' },
          { value: 'Comedy', label: 'Comedy (75)' }
        ])
      })
    })
  })

  describe('fetchMovies action', () => {
    const mockMovies = [
      { id: 1, title: 'Movie 1' },
      { id: 2, title: 'Movie 2' }
    ]
    const mockPagination = { current_page: 1, total_pages: 5 }

    it('should fetch movies successfully', async () => {
      const mockResponse = {
        data: {
          movies: mockMovies,
          pagination: mockPagination
        }
      }
      api.get.mockResolvedValue(mockResponse)

      await store.fetchMovies()

      expect(api.get).toHaveBeenCalledWith('/movies', {
        params: { page: 1, per_page: 20 }
      })
      expect(store.movies).toEqual(mockMovies)
      expect(store.pagination).toEqual(mockPagination)
      expect(store.loading).toBe(false)
      expect(store.error).toBeNull()
    })

    it('should handle fetch error', async () => {
      const mockError = new Error('Network error')
      api.get.mockRejectedValue(mockError)

      await store.fetchMovies()

      expect(store.error).toBe('Failed to load movies')
      expect(store.loading).toBe(false)
    })

    it('should build correct API params with filters', async () => {
      const mockResponse = { data: { movies: [], pagination: {} } }
      api.get.mockResolvedValue(mockResponse)

      const filters = {
        search: 'action',
        genres: ['Action', 'Comedy'],
        min_rating: 7.0,
        year: 2023,
        sort_by: 'rating'
      }

      await store.fetchMovies(1, 20, filters)

      expect(api.get).toHaveBeenCalledWith('/movies', {
        params: {
          page: 1,
          per_page: 20,
          search: 'action',
          genres: 'Action,Comedy',
          min_rating: 7.0,
          year: 2023,
          sort_by: 'rating'
        }
      })
    })

    it('should set loading state correctly', async () => {
      const mockResponse = { data: { movies: [], pagination: {} } }
      api.get.mockImplementation(() => {
        expect(store.loading).toBe(true)
        return Promise.resolve(mockResponse)
      })

      await store.fetchMovies()

      expect(store.loading).toBe(false)
    })
  })

  describe('fetchBestFilms action', () => {
    const mockBestFilms = [
      { id: 1, title: 'Best Movie 1' },
      { id: 2, title: 'Best Movie 2' }
    ]
    const mockPagination = { current_page: 1, total_pages: 3 }

    it('should fetch best films successfully', async () => {
      const mockResponse = {
        data: {
          movies: mockBestFilms,
          pagination: mockPagination
        }
      }
      api.get.mockResolvedValue(mockResponse)

      await store.fetchBestFilms()

      expect(api.get).toHaveBeenCalledWith('/movies/best_films', {
        params: { page: 1, per_page: 20 }
      })
      expect(store.bestFilms).toEqual(mockBestFilms)
      expect(store.bestFilmsPagination).toEqual(mockPagination)
      expect(store.bestFilmsLoading).toBe(false)
      expect(store.error).toBeNull()
    })

    it('should handle fetch error', async () => {
      const mockError = new Error('Network error')
      api.get.mockRejectedValue(mockError)

      await store.fetchBestFilms()

      expect(store.error).toBe('Failed to load best films')
      expect(store.bestFilmsLoading).toBe(false)
    })
  })

  describe('fetchGenres action', () => {
    const mockGenres = [
      { id: 1, name: 'Action', movies_count: 100 },
      { id: 2, name: 'Comedy', movies_count: 75 }
    ]

    it('should fetch genres successfully', async () => {
      const mockResponse = { data: { genres: mockGenres } }
      api.get.mockResolvedValue(mockResponse)

      await store.fetchGenres()

      expect(api.get).toHaveBeenCalledWith('/movies/genres')
      expect(store.genres).toEqual(mockGenres)
      expect(store.genresLoading).toBe(false)
    })

    it('should not fetch genres if already loaded', async () => {
      store.genres = mockGenres

      await store.fetchGenres()

      expect(api.get).not.toHaveBeenCalled()
    })

    it('should handle fetch error', async () => {
      const mockError = new Error('Network error')
      api.get.mockRejectedValue(mockError)

      await store.fetchGenres()

      expect(store.genresLoading).toBe(false)
    })
  })

  describe('applyFilters action', () => {
    it('should apply filters and fetch movies', async () => {
      const mockResponse = { data: { movies: [], pagination: {} } }
      api.get.mockResolvedValue(mockResponse)

      const filters = { search: 'action', min_rating: 7.0 }
      await store.applyFilters(filters)

      expect(store.filters).toEqual(filters)
      expect(api.get).toHaveBeenCalledWith('/movies', {
        params: { page: 1, per_page: 20, search: 'action', min_rating: 7.0 }
      })
    })
  })

  describe('toggleLike action', () => {
    beforeEach(() => {
      store.movies = [
        { id: 1, title: 'Movie 1', liked_by_current_user: false, likes_count: 5 },
        { id: 2, title: 'Movie 2', liked_by_current_user: true, likes_count: 10 }
      ]
    })

    it('should like a movie', async () => {
      const mockResponse = { data: { liked: true, likes_count: 6 } }
      api.post.mockResolvedValue(mockResponse)

      const result = await store.toggleLike(1)

      expect(api.post).toHaveBeenCalledWith('/movies/1/like')
      expect(store.movies[0].liked_by_current_user).toBe(true)
      expect(store.movies[0].likes_count).toBe(6)
      expect(result).toEqual(mockResponse.data)
    })

    it('should unlike a movie', async () => {
      const mockResponse = { data: { liked: false, likes_count: 9 } }
      api.delete.mockResolvedValue(mockResponse)

      const result = await store.toggleLike(2)

      expect(api.delete).toHaveBeenCalledWith('/movies/2/like')
      expect(store.movies[1].liked_by_current_user).toBe(false)
      expect(store.movies[1].likes_count).toBe(9)
      expect(result).toEqual(mockResponse.data)
    })

    it('should handle movie not found', async () => {
      const result = await store.toggleLike(999)

      expect(api.post).not.toHaveBeenCalled()
      expect(api.delete).not.toHaveBeenCalled()
      expect(result).toBeUndefined()
    })

    it('should handle API error', async () => {
      const mockError = new Error('Network error')
      api.post.mockRejectedValue(mockError)

      await expect(store.toggleLike(1)).rejects.toThrow('Network error')
    })

    it('should update both movies and bestFilms lists', async () => {
      store.bestFilms = [
        { id: 1, title: 'Movie 1', liked_by_current_user: false, likes_count: 5 }
      ]
      
      const mockResponse = { data: { liked: true, likes_count: 6 } }
      api.post.mockResolvedValue(mockResponse)

      await store.toggleLike(1)

      expect(store.movies[0].liked_by_current_user).toBe(true)
      expect(store.movies[0].likes_count).toBe(6)
      expect(store.bestFilms[0].liked_by_current_user).toBe(true)
      expect(store.bestFilms[0].likes_count).toBe(6)
    })
  })

  describe('private methods', () => {
    describe('_buildApiParams', () => {
      it('should build basic params', () => {
        const params = store._buildApiParams(1, 20, {})
        expect(params).toEqual({ page: 1, per_page: 20 })
      })

      it('should include search when provided', () => {
        const params = store._buildApiParams(1, 20, { search: '  action  ' })
        expect(params).toEqual({ page: 1, per_page: 20, search: 'action' })
      })

      it('should include genres when provided', () => {
        const params = store._buildApiParams(1, 20, { genres: ['Action', 'Comedy'] })
        expect(params).toEqual({ page: 1, per_page: 20, genres: 'Action,Comedy' })
      })

      it('should include all filters', () => {
        const filters = {
          search: 'action',
          genres: ['Action'],
          min_rating: 7.0,
          year: 2023,
          sort_by: 'rating'
        }
        const params = store._buildApiParams(1, 20, filters)
        expect(params).toEqual({
          page: 1,
          per_page: 20,
          search: 'action',
          genres: 'Action',
          min_rating: 7.0,
          year: 2023,
          sort_by: 'rating'
        })
      })

      it('should not include default sort_by', () => {
        const params = store._buildApiParams(1, 20, { sort_by: 'created_at' })
        expect(params).toEqual({ page: 1, per_page: 20 })
      })
    })

    describe('_findMovie', () => {
      beforeEach(() => {
        store.movies = [{ id: 1, title: 'Movie 1' }]
        store.bestFilms = [{ id: 2, title: 'Movie 2' }]
      })

      it('should find movie in movies list', () => {
        const movie = store._findMovie(1)
        expect(movie).toEqual({ id: 1, title: 'Movie 1' })
      })

      it('should find movie in bestFilms list', () => {
        const movie = store._findMovie(2)
        expect(movie).toEqual({ id: 2, title: 'Movie 2' })
      })

      it('should return undefined when movie not found', () => {
        const movie = store._findMovie(999)
        expect(movie).toBeUndefined()
      })
    })
  })
})
