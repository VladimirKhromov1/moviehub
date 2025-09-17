<script setup>
import { useAuthStore } from '@/stores/auth'

const authStore = useAuthStore()
</script>

<template>
  <div class="home-container">
    <div class="hero-section">
      <h1 class="hero-title">Welcome to MovieHub</h1>

      <div v-if="authStore.isAuthenticated" class="authenticated-content">
        <p class="hero-subtitle">
          Hello {{ authStore.user?.email }}! Ready to explore movies?
        </p>
        <div class="action-buttons">
          <button class="cta-button">Browse Movies</button>
          <button class="cta-button secondary">My Lists</button>
        </div>
      </div>

      <div v-else class="guest-content">
        <p class="hero-subtitle">
          Discover, organize, and share your favorite movies
        </p>
        <div class="action-buttons">
          <router-link to="/register" class="cta-button">Get Started</router-link>
          <router-link to="/login" class="cta-button secondary">Sign In</router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home-container {
  padding: 64px 16px;
  text-align: center;
}

.hero-section {
  max-width: 800px;
  margin: 0 auto;
}

.hero-title {
  font-size: 48px;
  font-weight: bold;
  color: #1f2937;
  margin-bottom: 16px;
}

.hero-subtitle {
  font-size: 20px;
  color: #6b7280;
  margin-bottom: 32px;
}

.action-buttons {
  display: flex;
  gap: 16px;
  justify-content: center;
  flex-wrap: wrap;
}

.cta-button {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: bold;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s;
  background-color: #3b82f6;
  color: white;
}

.cta-button:hover {
  background-color: #2563eb;
  transform: translateY(-1px);
}

.cta-button.secondary {
  background-color: #6b7280;
}

.cta-button.secondary:hover {
  background-color: #4b5563;
}
</style>
