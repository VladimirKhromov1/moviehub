export default {
  testEnvironment: 'jsdom',
  
  // File extensions to consider
  moduleFileExtensions: ['js', 'vue', 'json'],
  
  // Transform files
  transform: {
    '^.+\\.vue$': '@vue/vue3-jest',
    '^.+\\.js$': 'babel-jest',
  },
  
  // Test match patterns
  testMatch: [
    '**/tests/**/*.spec.js',
    '**/tests/**/*.test.js',
    '**/__tests__/**/*.js',
    '**/*.test.js',
    '**/*.spec.js'
  ],
  
  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  
  // Coverage
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.{js,vue}',
    '!src/main.js',
    '!src/**/*.d.ts',
    '!**/node_modules/**'
  ],
  
  // Test environment options
  testEnvironmentOptions: {
    customExportConditions: ['node', 'node-addons'],
  },
  
  // Handle CSS and other assets and path mapping
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy'
  }
}
