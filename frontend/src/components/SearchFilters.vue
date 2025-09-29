<script setup>
import { ref, computed, watch, onMounted, nextTick } from 'vue'
import { useMoviesStore } from '@/stores/movies'
import { debounce } from 'lodash-es'

const moviesStore = useMoviesStore()

const localFilters = ref({
  search: '',
  genres: [],
  min_rating: '',
  year: '',
  sort_by: 'created_at'
})

const availableGenres = computed(() => moviesStore.genres)
const loading = computed(() => moviesStore.loading)
const totalResults = computed(() => moviesStore.pagination?.total_count || 0)

const hasActiveFilters = computed(() => moviesStore.hasActiveFilters)

const yearOptions = computed(() => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let year = currentYear; year >= 1990; year--) {
    years.push(year)
  }
  return years
})

const debouncedApplyFilters = debounce(() => {
  applyFilters()
}, 800)

const debouncedSearchFilters = debounce(() => {
  applyFilters()
}, 1000)

const applyFilters = () => {
  const filters = { ...localFilters.value }
  moviesStore.applyFilters(filters)
}

const resetFilters = (keys = []) => {
  keys.forEach(key => {
    if (key === 'genres') {
      localFilters.value[key] = []
    } else if (key === 'sort_by') {
      localFilters.value[key] = 'created_at'
    } else {
      localFilters.value[key] = ''
    }
  })
  applyFilters()
}

const resetAllFilters = () => {
  localFilters.value.search = ''
  localFilters.value.genres = []
  localFilters.value.min_rating = ''
  localFilters.value.year = ''
  localFilters.value.sort_by = 'created_at'

  applyFilters()
}

const removeGenre = (genreToRemove) => {
  localFilters.value.genres = localFilters.value.genres.filter(
    genre => genre !== genreToRemove
  )
  applyFilters()
}

const handleGenreChange = (genreName, isChecked) => {
  if (isChecked) {
    if (!localFilters.value.genres.includes(genreName)) {
      localFilters.value.genres.push(genreName)
    }
  } else {
    localFilters.value.genres = localFilters.value.genres.filter(
      genre => genre !== genreName
    )
  }
  debouncedApplyFilters()
}

let isUpdating = false

watch(
  () => localFilters.value.search,
  (newValue, oldValue) => {
    if (isUpdating || newValue === oldValue) return
    if (newValue.trim() === '') {
      applyFilters()
    } else {
      debouncedSearchFilters()
    }
  }
)

watch(
  () => [
    localFilters.value.min_rating,
    localFilters.value.year,
    localFilters.value.sort_by
  ],
  (newValues, oldValues) => {
    if (isUpdating || JSON.stringify(newValues) === JSON.stringify(oldValues)) return
    debouncedApplyFilters()
  },
  { deep: true }
)

onMounted(async () => {
  isUpdating = true
  await moviesStore.fetchGenres()

  localFilters.value = { ...moviesStore.filters }

  await nextTick()
  isUpdating = false
})
</script>

<template>
  <div class="search-filters">
    <!-- Search string -->
    <div class="search-section">
      <div class="search-input-wrapper">
        <input
          v-model="localFilters.search"
          type="text"
          placeholder="Search movies by title or description..."
          class="search-input"
          :disabled="loading"
        />
        <button
          v-if="localFilters.search"
          @click="resetFilters(['search'])"
          class="clear-search-btn"
          type="button"
          :disabled="loading"
        >
          ✕
        </button>
      </div>
    </div>

    <!-- Filters -->
    <div class="filters-section">
      <div class="filters-grid">
        <!-- Genres -->
        <div class="filter-group">
          <label class="filter-label">Genres</label>
          <div class="genres-container">
            <div class="genres-grid">
              <label
                v-for="genre in availableGenres"
                :key="genre.id"
                class="genre-checkbox"
              >
                <input
                  type="checkbox"
                  :value="genre.name"
                  :checked="localFilters.genres.includes(genre.name)"
                  @change="handleGenreChange(genre.name, $event.target.checked)"
                  :disabled="loading"
                />
                <span class="genre-label">{{ genre.name }} ({{ genre.movies_count }})</span>
              </label>
            </div>
          </div>

          <!-- Selected genres -->
          <div v-if="localFilters.genres.length > 0" class="selected-genres">
            <span
              v-for="genre in localFilters.genres"
              :key="genre"
              class="genre-tag"
            >
              {{ genre }}
              <button
                @click="removeGenre(genre)"
                class="remove-genre"
                :disabled="loading"
              >
                ×
              </button>
            </span>
          </div>
        </div>

        <!-- Min rating -->
        <div class="filter-group">
          <label class="filter-label">Min Rating</label>
          <select
            v-model="localFilters.min_rating"
            class="filter-select"
            :disabled="loading"
          >
            <option value="">Any Rating</option>
            <option value="6">6.0+ ⭐</option>
            <option value="7">7.0+ ⭐⭐</option>
            <option value="8">8.0+ ⭐⭐⭐</option>
            <option value="9">9.0+ ⭐⭐⭐⭐</option>
          </select>
        </div>

        <!-- Year -->
        <div class="filter-group">
          <label class="filter-label">Release Year</label>
          <select
            v-model="localFilters.year"
            class="filter-select"
            :disabled="loading"
          >
            <option value="">Any Year</option>
            <option v-for="year in yearOptions" :key="year" :value="year">
              {{ year }}
            </option>
          </select>
        </div>

        <!-- Sort -->
        <div class="filter-group">
          <label class="filter-label">Sort By</label>
          <select
            v-model="localFilters.sort_by"
            class="filter-select"
            :disabled="loading"
          >
            <option value="created_at">🆕 Newest Added</option>
            <option value="rating">⭐ Highest Rated</option>
            <option value="year">📅 Release Date</option>
            <option value="popularity">❤️ Most Popular</option>
            <option value="title">🔤 Alphabetical</option>
          </select>
        </div>
      </div>

      <!-- Actions and stats -->
      <div class="filter-actions">
        <div class="filter-controls">
          <button
            v-if="hasActiveFilters"
            @click="resetAllFilters"
            class="clear-all-btn"
            :disabled="loading"
          >
            🗑️ Clear All Filters
          </button>
        </div>

        <div class="results-info">
          <div class="results-count" :class="{ 'updating': loading }">
            <template v-if="loading">
              <div class="mini-spinner"></div>
              <span>Updating...</span>
            </template>
            <template v-else>
              <strong>{{ totalResults }}</strong> movies found
              <span v-if="hasActiveFilters" class="filtered-note">(filtered)</span>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.search-filters {
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  padding: 24px;
  margin-bottom: 24px;
  transition: opacity 0.2s ease;
}

.search-filters:has(.loading-indicator) {
  opacity: 0.8;
}

.search-section {
  margin-bottom: 20px;
}

.search-input-wrapper {
  position: relative;
  max-width: 500px;
}

.search-input {
  width: 100%;
  padding: 14px 16px;
  padding-right: 40px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 16px;
  transition: all 0.2s ease;
}

.search-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-input:disabled {
  background-color: #f9fafb;
  cursor: not-allowed;
}

.clear-search-btn {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  font-size: 18px;
  color: #6b7280;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.clear-search-btn:hover:not(:disabled) {
  background-color: #f3f4f6;
}

.clear-search-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.filters-section {
  border-top: 1px solid #e5e7eb;
  padding-top: 20px;
}

.filters-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 24px;
  margin-bottom: 24px;
}

.filter-group {
  display: flex;
  flex-direction: column;
}

.filter-label {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
  margin-bottom: 8px;
}

.filter-select {
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  background: white;
  transition: border-color 0.2s;
}

.filter-select:focus {
  outline: none;
  border-color: #3b82f6;
}

.filter-select:disabled {
  background-color: #f9fafb;
  cursor: not-allowed;
}

.genres-container {
  max-height: 200px;
  overflow-y: auto;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  padding: 8px;
}

.genres-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 4px;
}

.genre-checkbox {
  display: flex;
  align-items: center;
  padding: 4px 8px;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.genre-checkbox:hover {
  background-color: #f3f4f6;
}

.genre-checkbox input[type="checkbox"] {
  margin-right: 8px;
}

.genre-label {
  font-size: 13px;
  color: #374151;
}

.selected-genres {
  margin-top: 8px;
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.genre-tag {
  display: inline-flex;
  align-items: center;
  background: #eff6ff;
  color: #1d4ed8;
  padding: 4px 8px;
  border-radius: 16px;
  font-size: 12px;
  font-weight: 500;
}

.remove-genre {
  background: none;
  border: none;
  color: #1d4ed8;
  margin-left: 4px;
  cursor: pointer;
  font-size: 14px;
  padding: 0;
  width: 16px;
  height: 16px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.remove-genre:hover:not(:disabled) {
  background: #dbeafe;
}

.remove-genre:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.filter-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  padding-top: 16px;
  border-top: 1px solid #f3f4f6;
}

.filter-controls {
  display: flex;
  gap: 12px;
}

.clear-all-btn {
  padding: 10px 20px;
  background: #f87171;
  color: white;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
  display: flex;
  align-items: center;
  gap: 6px;
}

.clear-all-btn:hover:not(:disabled) {
  background: #ef4444;
}

.clear-all-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.results-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.loading-indicator {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #6b7280;
  font-size: 14px;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid #e5e7eb;
  border-top: 2px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.results-count {
  font-size: 14px;
  color: #374151;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.3s ease;
}

.results-count.updating {
  color: #6b7280;
}

.mini-spinner {
  width: 12px;
  height: 12px;
  border: 1.5px solid #e5e7eb;
  border-top: 1.5px solid #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

.filtered-note {
  color: #6b7280;
  font-size: 12px;
}

@media (max-width: 768px) {
  .filters-grid {
    grid-template-columns: 1fr;
  }

  .filter-actions {
    flex-direction: column;
    align-items: stretch;
  }

  .genres-grid {
    grid-template-columns: 1fr;
  }
}
</style>
