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

const formattedRating = computed(() => {
  const raw = props.movie && props.movie.rating
  const num = Number(raw)
  return Number.isFinite(num) ? num.toFixed(1) : '—'
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
  <div class="movie-card" role="article" tabindex="0">
    <div class="movie-poster">
      <img
        v-if="movie.poster_url"
        :src="movie.poster_url"
        :alt="movie.title"
        @error="handleImageError"
        loading="lazy"
      />
      <div v-else class="poster-placeholder" aria-hidden="true">
        <div class="placeholder-icon">🎬</div>
      </div>

      <!-- overlay like button on poster (mobile/compact) -->
      <button
        class="like-overlay like-button"
        @click.stop="handleLikeClick"
        :aria-pressed="movie.liked_by_current_user"
        :disabled="likeLoading"
        :class="{ liked: movie.liked_by_current_user }"
        title="Like"
      >
        <span class="heart">{{ movie.liked_by_current_user ? '❤️' : '🤍' }}</span>
        <span class="likes-count">{{ movie.likes_count }}</span>
      </button>
    </div>

    <div class="movie-info">
      <div class="title-row">
        <h3 class="movie-title">{{ movie.title }}</h3>

        <div class="meta-right">
          <div class="rating-badge" :title="`Rating: ${formattedRating}`">
            <svg class="star" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 17.3 6.18 20l1.18-6.88L2 9.75l6.91-.6L12 3l3.09 6.15L22 9.75l-5.36 3.36L17.82 20z"/></svg>
            <span class="rating">{{ formattedRating }}</span>
          </div>

          <div class="year-badge" v-if="movie.release_date" :title="`Release year: ${formatYear(movie.release_date)}`">
            <span class="year">{{ formatYear(movie.release_date) }}</span>
          </div>
        </div>
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
:root {
  --card-radius: 12px;
  --muted: #6b7280;
  --accent: #f87171;
  --bg: #ffffff;
  --shadow: 0 6px 18px rgba(15, 23, 42, 0.06);
}

.movie-card {
  display: flex;
  flex-direction: column;
  background: var(--bg);
  border-radius: var(--card-radius);
  box-shadow: var(--shadow);
  overflow: hidden;
  transition: transform 0.18s ease, box-shadow 0.18s ease;
  width: 100%;
  min-height: 420px;
}

.movie-card:hover {
  transform: translateY(-6px);
  box-shadow: 0 12px 36px rgba(15, 23, 42, 0.12);
}

.movie-poster {
  position: relative;
  height: 320px;
  background: linear-gradient(180deg, #f3f4f6 0%, #ffffff 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.movie-poster img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.poster-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.placeholder-icon {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 56px;
  color: #ffffff;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.like-overlay {
  position: absolute;
  right: 10px;
  top: 10px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  border: none;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(255,255,255,0.9);
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
  cursor: pointer;
  transition: transform .12s ease, background .12s;
  font-size: 14px;
  backdrop-filter: blur(4px);
}
.like-overlay:hover { transform: translateY(-2px); }
.like-overlay.liked {
  background: rgba(248, 113, 113, 0.12);
  border: 1px solid rgba(248, 113, 113, 0.18);
}

.movie-info {
  padding: 16px;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.title-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
}

.movie-title {
  margin: 0;
  font-size: 18px;
  line-height: 1.15;
  font-weight: 700;
  color: #0f172a;
  flex: 1 1 auto;
}

.meta-right {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-shrink: 0;
}

.rating-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 8px;
  border-radius: 999px;
  background: linear-gradient(90deg, rgba(245,158,11,0.12), rgba(245,158,11,0.06));
  border: 1px solid rgba(245,158,11,0.12);
  font-weight: 700;
  color: #92400e;
  font-size: 13px;
  min-width: 56px;
  justify-content: center;
}
.rating-badge .star { width: 14px; height: 14px; fill: #f59e0b; display: inline-block; }

.year-badge {
  background: #eef2ff;
  color: #3730a3;
  padding: 6px 9px;
  border-radius: 10px;
  font-size: 13px;
  font-weight: 600;
  border: 1px solid rgba(99,102,241,0.08);
}

.genres {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  margin-top: 4px;
}
.genre-tag {
  background: #f3f4f6;
  color: #374151;
  padding: 6px 8px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 600;
}

.description {
  margin: 0;
  color: var(--muted);
  font-size: 14px;
  line-height: 1.5;
  min-height: 40px;
}

.card-footer { display: none; }

/* Responsive tweaks */
@media (min-width: 900px) {
  .movie-card { min-height: 380px; }
  .movie-poster { height: 260px; }
}

@media (max-width: 640px) {
  .movie-card { min-height: 430px; }
  .movie-poster { height: 340px; }
  .like-overlay { right: 12px; top: 12px; }
}
</style>
