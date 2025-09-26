<script setup>
import {onMounted} from 'vue'
import {RouterView} from 'vue-router'
import {useAuthStore} from '@/stores/auth'

const authStore = useAuthStore()

onMounted(() => {
  authStore.checkAuth()
})

async function handleLogout() {
  await authStore.logout()
}
</script>

<template>
  <div id="app">
    <header class="navbar">
      <div class="nav-container">
        <div class="nav-brand">
          <router-link to="/" class="brand-link">
            🎬 MovieHub
          </router-link>
        </div>

        <nav class="nav-menu">
          <template v-if="authStore.isAuthenticated">
            <router-link to="/movies" class="nav-link">Movies</router-link>
            <span class="user-info">
              Welcome, {{ authStore.user?.email }}
            </span>
            <button @click="handleLogout" class="nav-button logout-button">
              Logout
            </button>
          </template>

          <template v-else>
            <router-link to="/login" class="nav-link">Login</router-link>
            <router-link to="/register" class="nav-link register-link">Register</router-link>
          </template>
        </nav>
      </div>
    </header>

    <main class="main-content">
      <RouterView/>
    </main>
  </div>
</template>

<style>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: system-ui, -apple-system, sans-serif;
  background-color: #f9fafb;
}

#app {
  min-height: 100vh;
}

.navbar {
  background-color: #1f2937;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.nav-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 64px;
}

.brand-link {
  font-size: 24px;
  font-weight: bold;
  color: white;
  text-decoration: none;
}

.brand-link:hover {
  color: #60a5fa;
}

.nav-menu {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-info {
  color: #d1d5db;
  font-size: 14px;
}

.nav-link {
  color: #d1d5db;
  text-decoration: none;
  padding: 8px 16px;
  border-radius: 6px;
  transition: background-color 0.2s;
}

.nav-link:hover {
  background-color: #374151;
  color: white;
}

.register-link {
  background-color: #3b82f6;
  color: white;
}

.register-link:hover {
  background-color: #2563eb;
}

.nav-button {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: background-color 0.2s;
}

.logout-button {
  background-color: #ef4444;
  color: white;
}

.logout-button:hover {
  background-color: #dc2626;
}

.main-content {
  min-height: calc(100vh - 64px);
}
</style>
