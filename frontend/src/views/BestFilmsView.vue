<script setup>
import { onMounted } from 'vue'
import { useMoviesStore } from '@/stores/movies'
import MoviesList from '@/components/MoviesList.vue'

const moviesStore = useMoviesStore()

const loadBestFilms = (page = 1) => {
  moviesStore.fetchBestFilms(page)
}

const handlePageChange = (page) => {
  loadBestFilms(page)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

const handleMovieClick = (movie) => {
  console.log('Movie clicked:', movie)
  // TODO: Navigate to movie details page
}

onMounted(() => {
  loadBestFilms()
})
</script>

<template>
  <div class="best-films-view">
    <header class="best-films-header">
      <h1>🏆 Best Films</h1>
      <p>Most loved movies by our community</p>
    </header>

    <MoviesList
      :movies="moviesStore.bestFilms"
      :pagination="moviesStore.bestFilmsPagination"
      :loading="moviesStore.bestFilmsLoading"
      :error="moviesStore.error"
      @page-change="handlePageChange"
      @movie-click="handleMovieClick"
      @retry="loadBestFilms"
    />
  </div>
</template>

<style scoped>
.best-films-view {
  min-height: 100vh;
  background: #f9fafb;
}

.best-films-header {
  text-align: center;
  padding: 40px 20px;
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: white;
}

.best-films-header h1 {
  font-size: 48px;
  margin: 0 0 12px 0;
  font-weight: bold;
}

.best-films-header p {
  font-size: 18px;
  opacity: 0.9;
  margin: 0;
}
</style>
