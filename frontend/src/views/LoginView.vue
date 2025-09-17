<script setup>
import LoginForm from '@/components/LoginForm.vue'
</script>

<template>
  <div class="auth-page">
    <LoginForm />

    <div class="auth-links">
      <p>
        Don't have an account?
        <router-link to="/register" class="link">Register here</router-link>
      </p>
    </div>
  </div>
</template>

<style scoped>
.auth-page {
  min-height: 100vh;
  background-color: #f5f5f5;
  padding: 48px 16px;
}

.auth-links {
  text-align: center;
  margin-top: 24px;
  color: #666;
}

.link {
  color: #3b82f6;
  text-decoration: none;
}

.link:hover {
  color: #1d4ed8;
  text-decoration: underline;
}
</style>
