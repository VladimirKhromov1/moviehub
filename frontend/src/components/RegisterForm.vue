<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')
const errors = ref([])

async function handleRegister() {
  errors.value = []
  const result = await authStore.register(
    email.value,
    password.value,
    passwordConfirmation.value
  )

  if (result.success) {
    router.push('/')
  } else {
    errors.value = result.errors
  }
}
</script>

<template>
  <div class="form-container">
    <h2 class="form-title">Register</h2>

    <form @submit.prevent="handleRegister">
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

      <div class="form-group">
        <label class="form-label">Confirm Password</label>
        <input
          v-model="passwordConfirmation"
          type="password"
          required
          class="form-input"
          placeholder="Confirm your password"
        />
      </div>

      <div v-if="errors.length" class="error-message">
        <ul class="error-list">
          <li v-for="error in errors" :key="error">{{ error }}</li>
        </ul>
      </div>

      <button
        type="submit"
        :disabled="authStore.loading"
        class="form-button register-button"
        :class="{ 'form-button-loading': authStore.loading }"
      >
        {{ authStore.loading ? 'Creating account...' : 'Register' }}
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
  border-color: #10b981;
  box-shadow: 0 0 0 3px rgba(16, 185, 129, 0.1);
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

.error-list {
  margin: 0;
  padding-left: 16px;
}

.form-button {
  width: 100%;
  color: white;
  padding: 12px;
  border: none;
  border-radius: 6px;
  font-size: 16px;
  font-weight: bold;
  cursor: pointer;
  transition: background-color 0.2s;
}

.register-button {
  background-color: #10b981;
}

.register-button:hover {
  background-color: #059669;
}

.form-button-loading {
  opacity: 0.6;
  cursor: not-allowed;
}

.form-button-loading:hover {
  background-color: #10b981;
}
</style>
