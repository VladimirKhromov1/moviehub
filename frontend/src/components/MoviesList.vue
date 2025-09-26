<script setup>
import MovieCard from './MovieCard.vue'

defineProps({
  movies: {
    type: Array,
    default: () => []
  },
  pagination: {
    type: Object,
    default: null
  },
  loading: {
    type: Boolean,
    default: false
  },
  error: {
    type: String,
    default: null
  }
})

defineEmits(['page-change', 'movie-click', 'retry'])
</script>

<template>
  <div class="movies-list">
    <div v-if="loading" class="loading">
      <div class="loading-spinner"></div>
      <p>Loading movies...</p>
    </div>

    <div v-else-if="error" class="error">
      <p>{{ error }}</p>
      <button @click="$emit('retry')" class="retry-button">
        Try Again
      </button>
    </div>

    <div v-else>
      <div class="movies-grid">
        <MovieCard
          v-for="movie in movies"
          :key="movie.id"
          :movie="movie"
          @click="$emit('movie-click', movie)"
        />
      </div>

      <div v-if="pagination" class="pagination">
        <button
          @click="$emit('page-change', pagination.current_page - 1)"
          :disabled="!pagination.has_prev"
          class="pagination-button"
        >
          ← Previous
        </button>

        <span class="pagination-info">
          Page {{ pagination.current_page }} of {{ pagination.total_pages }}
          ({{ pagination.total_count }} movies)
        </span>

        <button
          @click="$emit('page-change', pagination.current_page + 1)"
          :disabled="!pagination.has_next"
          class="pagination-button"
        >
          Next →
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.movies-list {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.loading, .error {
  text-align: center;
  padding: 60px 20px;
}

.loading-spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.retry-button {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  margin-top: 12px;
}

.retry-button:hover {
  background: #2563eb;
}

.movies-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  margin-bottom: 40px;
}

.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 20px;
  padding: 20px;
}

.pagination-button {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: background 0.2s;
}

.pagination-button:hover:not(:disabled) {
  background: #2563eb;
}

.pagination-button:disabled {
  background: #d1d5db;
  cursor: not-allowed;
}

.pagination-info {
  color: #6b7280;
  font-size: 14px;
}
</style>
