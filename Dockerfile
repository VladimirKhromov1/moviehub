# syntax=docker/dockerfile:1

FROM ruby:3.2.0

# Install OS deps
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends build-essential libpq-dev postgresql-client nodejs \
 && rm -rf /var/lib/apt/lists/*

# Improve bundler speed/cache
ENV BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=/usr/local/bundle

WORKDIR /app

# Pre-copy Gemfiles for bundle cache
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy app
COPY . .

# Expose default Rails port
EXPOSE 3000

CMD ["bash", "-lc", "bundle exec rails server -b 0.0.0.0 -p 3000"]


