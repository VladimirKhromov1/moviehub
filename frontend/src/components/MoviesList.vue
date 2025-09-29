<script setup>
import { computed } from 'vue'
import MovieCard from './MovieCard.vue'

const props = defineProps({
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

const emit = defineEmits(['page-change', 'movie-click', 'retry'])

const getPageNumbers = computed(() => {
  if (!props.pagination) return []

  const current = props.pagination.current_page
  const total = props.pagination.total_pages
  const pages = []

  if (total <= 7) {
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    if (current <= 4) {
      pages.push(1, 2, 3, 4, 5, '...', total)
    } else if (current >= total - 3) {
      pages.push(1, '...', total - 4, total - 3, total - 2, total - 1, total)
    } else {
      pages.push(1, '...', current - 1, current, current + 1, '...', total)
    }
  }

  return pages
})
</script>

<template>
  <div class="movies-list">
    <div v-if="loading" class="loading-state">
      <div class="loading-spinner"></div>
      <p class="loading-text">🎬 Loading movies...</p>
    </div>

    <div v-else-if="error" class="error-state">
      <div class="error-icon">⚠️</div>
      <h3 class="error-title">Oops! Something went wrong</h3>
      <p class="error-message">{{ error }}</p>
      <button @click="emit('retry')" class="retry-button">
        🔄 Try Again
      </button>
    </div>

    <div v-else-if="movies.length === 0" class="empty-state">
      <div class="empty-icon">🔍</div>
      <h3 class="empty-title">No movies found</h3>
      <p class="empty-message">Try adjusting your search or filters</p>
    </div>

    <div v-else class="movies-content">
      <div class="movies-grid" :class="{ 'loading-state': loading }">
        <TransitionGroup name="movie-list" tag="div" class="movies-grid-inner" appear>
          <MovieCard
            v-for="movie in movies"
            :key="`movie-${movie.id}`"
            :movie="movie"
            @click="emit('movie-click', movie)"
          />
        </TransitionGroup>
      </div>

      <div v-if="pagination && pagination.total_pages > 1" class="pagination">
        <button
          @click="emit('page-change', pagination.current_page - 1)"
          :disabled="!pagination.has_prev || loading"
          class="pagination-button prev-button"
        >
          ← Previous
        </button>

        <div class="page-numbers">
          <template v-for="page in getPageNumbers" :key="page">
            <button
              v-if="page !== '...'"
              @click="emit('page-change', page)"
              :disabled="loading"
              class="page-number"
              :class="{ active: page === pagination.current_page }"
            >
              {{ page }}
            </button>
            <span v-else class="page-ellipsis">...</span>
          </template>
        </div>

        <button
          @click="emit('page-change', pagination.current_page + 1)"
          :disabled="!pagination.has_next || loading"
          class="pagination-button next-button"
        >
          Next →
        </button>
      </div>

      <div class="results-summary">
        <p class="summary-text">
          Showing {{ ((pagination?.current_page || 1) - 1) * (pagination?.per_page || 20) + 1 }}
          to {{ Math.min((pagination?.current_page || 1) * (pagination?.per_page || 20), pagination?.total_count || 0) }}
          of {{ pagination?.total_count || 0 }} movies
        </p>
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

.loading-state, .error-state, .empty-state {
  text-align: center;
  padding: 80px 20px;
}

.loading-spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e5e7eb;
  border-top: 4px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

.loading-text {
  font-size: 18px;
  color: #6b7280;
  margin: 0;
}

.error-icon, .empty-icon {
  font-size: 48px;
  margin-bottom: 16px;
}

.error-title, .empty-title {
  font-size: 24px;
  font-weight: 600;
  color: #374151;
  margin: 0 0 8px 0;
}

.error-message, .empty-message {
  font-size: 16px;
  color: #6b7280;
  margin: 0 0 24px 0;
}

.retry-button {
  background: #3b82f6;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  font-size: 16px;
  transition: background 0.2s;
}

.retry-button:hover {
  background: #2563eb;
}

.movies-content {
  position: relative;
  min-height: 600px;
}

.movies-grid {
  margin-bottom: 40px;
  transition: opacity 0.3s ease;
}

.movies-grid.loading-state {
  opacity: 0.8;
}

.movies-grid-inner {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
}
.pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  padding: 20px;
  flex-wrap: wrap;
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
  white-space: nowrap;
}

.pagination-button:hover:not(:disabled) {
  background: #2563eb;
}

.pagination-button:disabled {
  background: #d1d5db;
  cursor: not-allowed;
}

.page-numbers {
  display: flex;
  align-items: center;
  gap: 4px;
  margin: 0 12px;
}

.page-number {
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
  padding: 8px 12px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
  min-width: 40px;
}

.page-number:hover:not(:disabled) {
  background: #f3f4f6;
  border-color: #9ca3af;
}

.page-number.active {
  background: #3b82f6;
  color: white;
  border-color: #3b82f6;
}

.page-number:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-ellipsis {
  color: #6b7280;
  padding: 8px 4px;
}

.results-summary {
  text-align: center;
  padding-top: 20px;
  border-top: 1px solid #e5e7eb;
}

.summary-text {
  color: #6b7280;
  font-size: 14px;
  margin: 0;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .pagination {
    flex-direction: column;
    gap: 12px;
  }

  .page-numbers {
    margin: 0;
  }

  .movies-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 16px;
  }
}
</style>
