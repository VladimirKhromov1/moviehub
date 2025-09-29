import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { useMoviesStore } from '@/stores/movies'
import { useAuthStore } from '@/stores/auth'
import MovieCard from '@/components/MovieCard.vue'

// Mock stores
jest.mock('@/stores/movies')
jest.mock('@/stores/auth')

describe('MovieCard Component', () => {
  let wrapper
  let mockMoviesStore
  let mockAuthStore
  
  const mockMovie = {
    id: 1,
    title: 'Test Movie',
    description: 'This is a test movie description that should be long enough to test truncation functionality properly and exceed the 150 character limit that is used in the component.',
    rating: 8.5,
    release_date: '2023-06-15',
    poster_url: 'https://example.com/poster.jpg',
    genres: ['Action', 'Drama'],
    likes_count: 42,
    liked_by_current_user: false
  }

  beforeEach(() => {
    // Mock store implementations
    mockMoviesStore = {
      toggleLike: jest.fn().mockResolvedValue()
    }
    mockAuthStore = {
      isAuthenticated: true
    }
    
    useMoviesStore.mockReturnValue(mockMoviesStore)
    useAuthStore.mockReturnValue(mockAuthStore)

    const pinia = createPinia()
    
    wrapper = mount(MovieCard, {
      props: {
        movie: mockMovie
      },
      global: {
        plugins: [pinia]
      }
    })
  })

  afterEach(() => {
    wrapper.unmount()
    jest.clearAllMocks()
  })

  describe('rendering', () => {
    it('should render movie information correctly', () => {
      expect(wrapper.find('.movie-title').text()).toBe('Test Movie')
      expect(wrapper.find('.rating').text()).toContain('8.5')
      expect(wrapper.find('.year').text()).toBe('2023')
      expect(wrapper.find('.likes-count').text()).toBe('42')
    })

    it('should render movie poster', () => {
      const poster = wrapper.find('.movie-poster img')
      expect(poster.exists()).toBe(true)
      expect(poster.attributes('src')).toBe('https://example.com/poster.jpg')
      expect(poster.attributes('alt')).toBe('Test Movie')
    })

    it('should render placeholder when no poster_url', async () => {
      await wrapper.setProps({
        movie: { ...mockMovie, poster_url: null }
      })

      expect(wrapper.find('.movie-poster img').exists()).toBe(false)
      expect(wrapper.find('.poster-placeholder').exists()).toBe(true)
      expect(wrapper.find('.poster-placeholder').text()).toContain('🎬')
    })

    it('should render genres', () => {
      const genreTags = wrapper.findAll('.genre-tag')
      expect(genreTags).toHaveLength(2)
      expect(genreTags[0].text()).toBe('Action')
      expect(genreTags[1].text()).toBe('Drama')
    })

    it('should truncate long descriptions', () => {
      const description = wrapper.find('.description').text()
      expect(description).toHaveLength(153) // 150 chars + '...'
      expect(description).toMatch(/\.\.\.$/)
    })

    it('should show full short descriptions', async () => {
      await wrapper.setProps({
        movie: { ...mockMovie, description: 'Short description' }
      })

      const description = wrapper.find('.description').text()
      expect(description).toBe('Short description')
      expect(description).not.toMatch(/\.\.\.$/)
    })

    it('should show default message when no description', async () => {
      await wrapper.setProps({
        movie: { ...mockMovie, description: null }
      })

      const description = wrapper.find('.description').text()
      expect(description).toBe('No description available')
    })
  })

  describe('like functionality', () => {
    it('should show empty heart when not liked', () => {
      const heart = wrapper.find('.heart')
      expect(heart.text()).toBe('🤍')
      expect(wrapper.find('.like-button').classes()).not.toContain('liked')
    })

    it('should show filled heart when liked', async () => {
      await wrapper.setProps({
        movie: { ...mockMovie, liked_by_current_user: true }
      })

      const heart = wrapper.find('.heart')
      expect(heart.text()).toBe('❤️')
      expect(wrapper.find('.like-button').classes()).toContain('liked')
    })

    it('should call toggleLike when like button is clicked', async () => {
      const likeButton = wrapper.find('.like-button')
      await likeButton.trigger('click')

      expect(mockMoviesStore.toggleLike).toHaveBeenCalledWith(1)
    })

    it('should not call toggleLike when user is not authenticated', async () => {
      mockAuthStore.isAuthenticated = false

      const likeButton = wrapper.find('.like-button')
      await likeButton.trigger('click')

      expect(mockMoviesStore.toggleLike).not.toHaveBeenCalled()
    })

    it('should disable like button when loading', async () => {
      // Simulate loading state
      await wrapper.vm.$nextTick(() => {
        wrapper.vm.likeLoading = true
      })

      const likeButton = wrapper.find('.like-button')
      expect(likeButton.attributes('disabled')).toBeDefined()
    })

    it('should handle like toggle error gracefully', async () => {
      const consoleSpy = jest.spyOn(console, 'error').mockImplementation()
      mockMoviesStore.toggleLike.mockRejectedValue(new Error('Network error'))

      const likeButton = wrapper.find('.like-button')
      await likeButton.trigger('click')

      expect(consoleSpy).toHaveBeenCalledWith('Failed to toggle like:', expect.any(Error))
      consoleSpy.mockRestore()
    })
  })

  describe('computed properties', () => {
    it('should compute truncatedDescription correctly', () => {
      expect(wrapper.vm.truncatedDescription).toHaveLength(153)
    })

    it('should compute truncatedDescription for short text', async () => {
      await wrapper.setProps({
        movie: { ...mockMovie, description: 'Short' }
      })
      
      expect(wrapper.vm.truncatedDescription).toBe('Short')
    })
  })

  describe('methods', () => {
    describe('formatYear', () => {
      it('should format date to year', () => {
        expect(wrapper.vm.formatYear('2023-06-15')).toBe(2023)
      })

      it('should return "Unknown" for invalid date', () => {
        expect(wrapper.vm.formatYear(null)).toBe('Unknown')
        expect(wrapper.vm.formatYear('')).toBe('Unknown')
      })
    })

    describe('handleImageError', () => {
      it('should hide image and show placeholder on error', () => {
        const mockEvent = {
          target: {
            style: { display: '' },
            nextElementSibling: {
              style: { display: 'none' }
            }
          }
        }

        wrapper.vm.handleImageError(mockEvent)

        expect(mockEvent.target.style.display).toBe('none')
        expect(mockEvent.target.nextElementSibling.style.display).toBe('flex')
      })
    })

    describe('handleLikeClick', () => {
      it('should handle successful like toggle', async () => {
        await wrapper.vm.handleLikeClick()

        expect(mockMoviesStore.toggleLike).toHaveBeenCalledWith(1)
      })

      it('should return early when user not authenticated', async () => {
        mockAuthStore.isAuthenticated = false

        await wrapper.vm.handleLikeClick()

        expect(mockMoviesStore.toggleLike).not.toHaveBeenCalled()
      })

      it('should set loading state correctly', async () => {
        let resolvePromise
        const promise = new Promise(resolve => { resolvePromise = resolve })
        mockMoviesStore.toggleLike.mockReturnValue(promise)

        const clickPromise = wrapper.vm.handleLikeClick()
        
        // Should be loading
        expect(wrapper.vm.likeLoading).toBe(true)

        resolvePromise()
        await clickPromise

        // Should not be loading
        expect(wrapper.vm.likeLoading).toBe(false)
      })
    })
  })

  describe('accessibility', () => {
    it('should have proper alt text for movie poster', () => {
      const poster = wrapper.find('.movie-poster img')
      expect(poster.attributes('alt')).toBe('Test Movie')
    })

    it('should have proper button semantics for like button', () => {
      const likeButton = wrapper.find('.like-button')
      expect(likeButton.element.tagName).toBe('BUTTON')
    })
  })
})
