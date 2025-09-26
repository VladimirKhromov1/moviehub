<script setup>
import { onMounted } from 'vue'
import { useMoviesStore } from '@/stores/movies'
import MoviesList from '@/components/MoviesList.vue'

const moviesStore = useMoviesStore()

const loadMovies = (page = 1) => {
  moviesStore.fetchMovies(page)
}

const handlePageChange = (page) => {
  loadMovies(page)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleMovieClick = (movie) => {
  console.log('Movie clicked:', movie)
  // TODO: Navigate to movie details page
}

onMounted(() => {
  loadMovies()
})
</script>

<template>
  <div class="movies-view">
    <header class="movies-header">
      <h1>🎬 Movie Catalog</h1>
      <p>Discover amazing movies from our collection</p>
    </header>

    <MoviesList
      :movies="moviesStore.movies"
      :pagination="moviesStore.pagination"
      :loading="moviesStore.loading"
      :error="moviesStore.error"
      @page-change="handlePageChange"
      @movie-click="handleMovieClick"
      @retry="loadMovies"
    />
  </div>
</template>

<style scoped>
.movies-view {
  min-height: 100vh;
  background: #f9fafb;
}

.movies-header {
  text-align: center;
  padding: 40px 20px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.movies-header h1 {
  font-size: 48px;
  margin: 0 0 12px 0;
  font-weight: bold;
}

.movies-header p {
  font-size: 18px;
  opacity: 0.9;
  margin: 0;
}
</style>
