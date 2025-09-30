# MovieHub

Single‑page app (Rails API + Vue). Browse the catalog, search/filter/sort popular films, and vote with likes. “Best Films” ranks movies by total likes across all users.

## Quick Start

### 1. Clone the repository
```bash
git clone <repository-url>
cd moviehub
```

### 2. Set up TMDB API Key
You need a TMDB API key for movie synchronization:

1. Go to [TMDB API](https://www.themoviedb.org/settings/api)
2. Create an account and request an API key
3. Add the key to Rails credentials:
```bash
# Edit Rails credentials
docker-compose exec backend rails credentials:edit

# Add this line:
# tmdb_api_key: your_api_key_here
```

### 3. Start with Docker
```bash
docker-compose up -d
```

### 4. Open the application
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3000

## Basic Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down
```

## What's Running

- **Backend**: Rails API on port 3000
- **Frontend**: Vue.js on port 5173 (Vite dev server)
- **Database**: PostgreSQL on port 5432
- **Cache/Jobs**: Redis on port 6379
- **Background Jobs**: Sidekiq for movie synchronization

## Testing

### Backend Tests (Rails)
```bash
# Run all tests 
docker-compose exec -e RAILS_ENV=test backend bundle exec rspec
```

### Frontend Tests (Vue.js)
```bash
# Run all tests 
docker-compose exec frontend npm test --silent
```

### Test Results
- **Backend**: RSpec suite covers models, controllers, services
- **Frontend**: Jest suite covers components, stores, services

## 📁 Project Structure

```
├── app/                 # Rails API
├── frontend/           # Vue.js SPA
└── docker-compose.yml  # Docker configuration
```
