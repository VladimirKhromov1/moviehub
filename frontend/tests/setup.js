import '@testing-library/jest-dom'
import { config } from '@vue/test-utils'

// Global test configuration
config.global.stubs = {
  transition: false,
  'transition-group': false
}

// Console warning suppression for tests
const originalWarn = console.warn
console.warn = (...args) => {
  if (
    typeof args[0] === 'string' &&
    args[0].includes('[Vue warn]')
  ) {
    return
  }
  originalWarn(...args)
}