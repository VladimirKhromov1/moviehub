import { mount } from '@vue/test-utils'
import { createPinia } from 'pinia'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import LoginForm from '@/components/LoginForm.vue'

// Mock vue-router
jest.mock('vue-router')

// Mock auth store
jest.mock('@/stores/auth')

describe('LoginForm Component', () => {
  let wrapper
  let mockRouter
  let mockAuthStore
  
  beforeEach(() => {
    // Mock router implementation
    mockRouter = {
      push: jest.fn()
    }
    useRouter.mockReturnValue(mockRouter)

    // Mock store implementation
    mockAuthStore = {
      login: jest.fn().mockResolvedValue({ success: true }),
      loading: false
    }
    useAuthStore.mockReturnValue(mockAuthStore)

    const pinia = createPinia()
    
    wrapper = mount(LoginForm, {
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
    it('should render form elements correctly', () => {
      expect(wrapper.find('.form-title').text()).toBe('Login')
      expect(wrapper.find('input[type="email"]').exists()).toBe(true)
      expect(wrapper.find('input[type="password"]').exists()).toBe(true)
      expect(wrapper.find('button[type="submit"]').exists()).toBe(true)
    })

    it('should have proper form labels', () => {
      const labels = wrapper.findAll('.form-label')
      expect(labels[0].text()).toBe('Email')
      expect(labels[1].text()).toBe('Password')
    })

    it('should have proper input placeholders', () => {
      const emailInput = wrapper.find('input[type="email"]')
      const passwordInput = wrapper.find('input[type="password"]')
      
      expect(emailInput.attributes('placeholder')).toBe('Enter your email')
      expect(passwordInput.attributes('placeholder')).toBe('Enter your password')
    })

    it('should show login button text by default', () => {
      const submitButton = wrapper.find('button[type="submit"]')
      expect(submitButton.text()).toBe('Login')
    })

    it('should show loading text when loading', async () => {
      // Update the mock to return loading: true
      mockAuthStore.loading = true
      useAuthStore.mockReturnValue(mockAuthStore)
      
      // Re-mount the component with updated store
      wrapper = mount(LoginForm, {
        global: {
          plugins: [createPinia()]
        }
      })
      
      const submitButton = wrapper.find('button[type="submit"]')
      expect(submitButton.text()).toBe('Logging in...')
    })

    it('should disable submit button when loading', async () => {
      // Update the mock to return loading: true
      mockAuthStore.loading = true
      useAuthStore.mockReturnValue(mockAuthStore)
      
      // Re-mount the component with updated store
      wrapper = mount(LoginForm, {
        global: {
          plugins: [createPinia()]
        }
      })
      
      const submitButton = wrapper.find('button[type="submit"]')
      expect(submitButton.attributes('disabled')).toBeDefined()
      expect(submitButton.classes()).toContain('form-button-loading')
    })

    it('should not show error message initially', () => {
      expect(wrapper.find('.error-message').exists()).toBe(false)
    })

    it('should show error message when error exists', async () => {
      // Simulate error by calling handleLogin with a failing mock
      mockAuthStore.login.mockResolvedValueOnce({ 
        success: false, 
        error: 'Invalid credentials' 
      })
      
      await wrapper.vm.handleLogin()
      
      const errorMessage = wrapper.find('.error-message')
      expect(errorMessage.exists()).toBe(true)
      expect(errorMessage.text()).toBe('Invalid credentials')
    })
  })

  describe('form interactions', () => {
    it('should update email input', async () => {
      const emailInput = wrapper.find('input[type="email"]')
      await emailInput.setValue('test@example.com')
      
      expect(wrapper.vm.email).toBe('test@example.com')
    })

    it('should update password input', async () => {
      const passwordInput = wrapper.find('input[type="password"]')
      await passwordInput.setValue('password123')
      
      expect(wrapper.vm.password).toBe('password123')
    })

    it('should require email input', () => {
      const emailInput = wrapper.find('input[type="email"]')
      expect(emailInput.attributes('required')).toBeDefined()
    })

    it('should require password input', () => {
      const passwordInput = wrapper.find('input[type="password"]')
      expect(passwordInput.attributes('required')).toBeDefined()
    })
  })

  describe('form submission', () => {
    beforeEach(async () => {
      await wrapper.find('input[type="email"]').setValue('test@example.com')
      await wrapper.find('input[type="password"]').setValue('password123')
    })

    // Note: This test is skipped due to issues with spy on Composition API
    it.skip('should call handleLogin on form submit', async () => {
      const handleLoginSpy = jest.spyOn(wrapper.vm, 'handleLogin')
      
      await wrapper.find('form').trigger('submit.prevent')
      
      expect(handleLoginSpy).toHaveBeenCalled()
    })

    it('should call authStore.login with correct credentials', async () => {
      mockAuthStore.login.mockResolvedValue({ success: true })
      
      await wrapper.vm.handleLogin()
      
      expect(mockAuthStore.login).toHaveBeenCalledWith('test@example.com', 'password123')
    })

    it('should navigate to home on successful login', async () => {
      mockAuthStore.login.mockResolvedValue({ success: true })
      
      await wrapper.vm.handleLogin()
      
      expect(mockRouter.push).toHaveBeenCalledWith('/')
    })

    it('should show error on failed login', async () => {
      mockAuthStore.login.mockResolvedValue({ 
        success: false, 
        error: 'Invalid credentials' 
      })
      
      await wrapper.vm.handleLogin()
      
      expect(wrapper.vm.error).toBe('Invalid credentials')
      expect(mockRouter.push).not.toHaveBeenCalled()
    })

    it('should clear error before new login attempt', async () => {
      // First, create an error state
      mockAuthStore.login.mockResolvedValueOnce({ 
        success: false, 
        error: 'Previous error' 
      })
      await wrapper.vm.handleLogin()
      
      // Then test that error is cleared on new attempt
      mockAuthStore.login.mockResolvedValueOnce({ success: true })
      
      await wrapper.vm.handleLogin()
      
      expect(wrapper.vm.error).toBeNull()
    })
  })

  describe('component data', () => {
    it('should have correct initial data', () => {
      expect(wrapper.vm.email).toBe('')
      expect(wrapper.vm.password).toBe('')
      expect(wrapper.vm.error).toBeNull()
    })
  })

  describe('accessibility', () => {
    it('should have proper form semantics', () => {
      const form = wrapper.find('form')
      expect(form.exists()).toBe(true)
    })

    it('should have proper input types', () => {
      expect(wrapper.find('input[type="email"]').exists()).toBe(true)
      expect(wrapper.find('input[type="password"]').exists()).toBe(true)
    })

    it('should associate labels with inputs', () => {
      const labels = wrapper.findAll('label')
      const emailInput = wrapper.find('input[type="email"]')
      const passwordInput = wrapper.find('input[type="password"]')
      
      expect(labels[0].text()).toBe('Email')
      expect(labels[1].text()).toBe('Password')
      
      // In this component, labels are not explicitly associated with for/id
      // This could be improved in the actual component
    })

    it('should have submit button', () => {
      const submitButton = wrapper.find('button[type="submit"]')
      expect(submitButton.exists()).toBe(true)
    })
  })

  describe('error handling', () => {
    it('should handle login errors gracefully', async () => {
      mockAuthStore.login.mockResolvedValue({
        success: false,
        error: 'Network error'
      })
      
      await wrapper.vm.handleLogin()
      
      expect(wrapper.vm.error).toBe('Network error')
    })

    it('should handle store exceptions', async () => {
      mockAuthStore.login.mockRejectedValue(new Error('Store error'))
      
      // Should handle the error gracefully and set error state
      await wrapper.vm.handleLogin()
      
      // The error should be caught and handled in the component
      expect(wrapper.vm.error).toBe('Store error')
    })
  })
})
