# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MovieGenre, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:movie) }
    it { is_expected.to belong_to(:genre) }
  end


  describe 'creating movie_genre associations' do
    let(:movie) { create(:movie) }
    let(:genre) { create(:genre) }

    it 'connects movie and genre' do
      movie_genre = create(:movie_genre, movie: movie, genre: genre)

      expect(movie_genre.movie).to eq(movie)
      expect(movie_genre.genre).to eq(genre)
      expect(movie.genres).to include(genre)
      expect(genre.movies).to include(movie)
    end

    it 'allows same movie with different genres' do
      genre2 = create(:genre)

      movie_genre1 = create(:movie_genre, movie: movie, genre: genre)
      movie_genre2 = create(:movie_genre, movie: movie, genre: genre2)

      expect(movie_genre1).to be_valid
      expect(movie_genre2).to be_valid
      expect(movie.genres).to include(genre, genre2)
    end

    it 'allows same genre with different movies' do
      movie2 = create(:movie)

      movie_genre1 = create(:movie_genre, movie: movie, genre: genre)
      movie_genre2 = create(:movie_genre, movie: movie2, genre: genre)

      expect(movie_genre1).to be_valid
      expect(movie_genre2).to be_valid
      expect(genre.movies).to include(movie, movie2)
    end
  end
end
