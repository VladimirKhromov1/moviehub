<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const error = ref(null)

async function handleLogin() {
  error.value = null
  try {
    const result = await authStore.login(email.value, password.value)

    if (result.success) {
      router.push('/')
    } else {
      error.value = result.error
    }
  } catch (err) {
    error.value = err.message
  }
}
</script>

<template>
  <div class="form-container">
    <h2 class="form-title">Login</h2>

    <form @submit.prevent="handleLogin">
      <div class="form-group">
        <label class="form-label">Email</label>
        <input
          v-model="email"
          type="email"
          required
          class="form-input"
          placeholder="Enter your email"
        />
      </div>

      <div class="form-group">
        <label class="form-label">Password</label>
        <input
          v-model="password"
          type="password"
          required
          class="form-input"
          placeholder="Enter your password"
        />
      </div>

      <div v-if="error" class="error-message">
        {{ error }}
      </div>

      <button
        type="submit"
        :disabled="authStore.loading"
        class="form-button"
        :class="{ 'form-button-loading': authStore.loading }"
      >
        {{ authStore.loading ? 'Logging in...' : 'Login' }}
      </button>
    </form>
  </div>
</template>

<style scoped>
.form-container {
  max-width: 400px;
  margin: 0 auto;
  background: white;
  padding: 32px;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}

.form-title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 24px;
  text-align: center;
  color: #333;
}

.form-group {
  margin-bottom: 16px;
}

.form-label {
  display: block;
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 8px;
  color: #555;
}

.form-input {
  width: 100%;
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  font-size: 16px;
  box-sizing: border-box;
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.error-message {
  margin-bottom: 16px;
  padding: 12px;
  background-color: #fee;
  border: 1px solid #fcc;
  color: #c33;
  border-radius: 6px;
  font-size: 14px;
}

.form-button {
  width: 100%;
  background-color: #3b82f6;
  color: white;
  padding: 12px;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.2s;
}

.form-button:hover {
  background-color: #2563eb;
}

.form-button-loading {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-button-loading:hover {
  background-color: #3b82f6;
}
</style>
