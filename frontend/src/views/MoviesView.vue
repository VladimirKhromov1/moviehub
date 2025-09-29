<script setup>
import { onMounted, computed } from 'vue'
import { useMoviesStore } from '@/stores/movies'
import MoviesList from '@/components/MoviesList.vue'
import SearchFilters from '@/components/SearchFilters.vue'

const moviesStore = useMoviesStore()

const movies = computed(() => moviesStore.movies)
const pagination = computed(() => moviesStore.pagination)
const loading = computed(() => moviesStore.loading)
const error = computed(() => moviesStore.error)

const handlePageChange = (page) => {
  moviesStore.fetchMovies(page, 20, moviesStore.filters)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleRetry = () => {
  moviesStore.fetchMovies(1, 20, moviesStore.filters)
}

onMounted(() => {
  moviesStore.fetchMovies()
})
</script>

<template>
  <div class="movies-view">
    <header class="movies-header">
      <div class="header-content">
        <h1 class="header-title">🎬 Movie Catalog</h1>
        <p class="header-subtitle">
          Discover amazing movies from our collection
        </p>
      </div>
    </header>

    <main class="movies-main">
      <div class="container">
        <SearchFilters />

        <MoviesList
          :movies="movies"
          :pagination="pagination"
          :loading="loading"
          :error="error"
          @page-change="handlePageChange"
          @retry="handleRetry"
        />
      </div>
    </main>
  </div>
</template>

<style scoped>
.movies-view {
  min-height: 100vh;
  background: #f8fafc;
}

.movies-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 60px 0;
}

.header-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  text-align: center;
}

.header-title {
  font-size: clamp(32px, 5vw, 48px);
  font-weight: 700;
  margin: 0 0 16px 0;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-subtitle {
  font-size: 18px;
  opacity: 0.9;
  margin: 0;
  max-width: 600px;
  margin: 0 auto;
}

.movies-main {
  padding: 32px 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

@media (max-width: 768px) {
  .movies-header {
    padding: 40px 0;
  }

  .movies-main {
    padding: 20px 0;
  }
}
</style>
