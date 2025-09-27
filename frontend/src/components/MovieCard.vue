<script setup>
import { computed, ref } from 'vue'
import { useMoviesStore } from '@/stores/movies'
import { useAuthStore } from '@/stores/auth'

const props = defineProps({
  movie: {
    type: Object,
    required: true
  }
})

const moviesStore = useMoviesStore()
const authStore = useAuthStore()
const likeLoading = ref(false)

const truncatedDescription = computed(() => {
  if (!props.movie.description) return 'No description available'
  return props.movie.description.length > 150
    ? props.movie.description.substring(0, 150) + '...'
    : props.movie.description
})

const formatYear = (date) => {
  if (!date) return 'Unknown'
  return new Date(date).getFullYear()
}

const handleImageError = (event) => {
  event.target.style.display = 'none'
  event.target.nextElementSibling.style.display = 'flex'
}

const handleLikeClick = async () => {
  if (!authStore.isAuthenticated) {
    return
  }

  likeLoading.value = true
  try {
    await moviesStore.toggleLike(props.movie.id)
  } catch (error) {
    console.error('Failed to toggle like:', error)
  } finally {
    likeLoading.value = false
  }
}
</script>

<template>
  <div class="movie-card">
    <div class="movie-poster">
      <img
        v-if="movie.poster_url"
        :src="movie.poster_url"
        :alt="movie.title"
        @error="handleImageError"
      />
      <div v-else class="poster-placeholder">
        🎬
      </div>
    </div>

    <div class="movie-info">
      <h3 class="movie-title">{{ movie.title }}</h3>
      <div class="movie-meta">
        <div class="movie-actions">
          <button
            @click.stop="handleLikeClick"
            :disabled="likeLoading"
            class="like-button"
            :class="{ 'liked': movie.liked_by_current_user }"
          >
            <span class="heart">{{ movie.liked_by_current_user ? '❤️' : '🤍' }}</span>
            <span class="likes-count">{{ movie.likes_count }}</span>
          </button>
        </div>
        <span class="rating">⭐ {{ movie.rating }}</span>
        <span class="year">{{ formatYear(movie.release_date) }}</span>
      </div>
      <div class="genres">
        <span
          v-for="genre in movie.genres"
          :key="genre"
          class="genre-tag"
        >
          {{ genre }}
        </span>
      </div>
      <p class="description">{{ truncatedDescription }}</p>
    </div>
  </div>
</template>

<style scoped>
.movie-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: pointer;
}

.movie-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
}

.movie-poster {
  position: relative;
  height: 300px;
  overflow: hidden;
}

.movie-poster img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.poster-placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 48px;
  color: white;
}

.movie-info {
  padding: 16px;
}

.movie-title {
  font-size: 18px;
  font-weight: bold;
  margin: 0 0 8px 0;
  color: #1f2937;
}

.movie-meta {
  display: flex;
  gap: 12px;
  margin-bottom: 8px;
  font-size: 14px;
  color: #6b7280;
}

.rating {
  font-weight: 600;
  color: #f59e0b;
}

.genres {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-bottom: 12px;
}

.genre-tag {
  background: #e5e7eb;
  color: #374151;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.description {
  font-size: 14px;
  color: #6b7280;
  line-height: 1.4;
  margin: 0;
}

.movie-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 12px;
}

.like-button {
  display: flex;
  align-items: center;
  gap: 6px;
  background: none;
  border: 1px solid #e5e7eb;
  border-radius: 20px;
  padding: 6px 12px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 14px;
}

.like-button:hover {
  border-color: #f87171;
  background: #fef2f2;
}

.like-button.liked {
  border-color: #f87171;
  background: #fef2f2;
}

.like-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.heart {
  font-size: 16px;
}

.likes-count {
  font-weight: 500;
  color: #374151;
}
</style>
