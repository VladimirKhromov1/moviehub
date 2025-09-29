# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:movie).counter_cache(true) }
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:movie) { create(:movie) }

    subject { build(:like, user: user, movie: movie) }

    it { is_expected.to validate_uniqueness_of(:movie_id).scoped_to(:user_id) }

    context 'when user already liked the movie' do
      before { create(:like, user: user, movie: movie) }

      it 'validates uniqueness of movie_id scoped to user_id' do
        duplicate_like = build(:like, user: user, movie: movie)

        expect(duplicate_like).not_to be_valid
        expect(duplicate_like.errors[:movie_id]).to include('has already been taken')
      end
    end

    context 'when different users like the same movie' do
      let(:user2) { create(:user) }

      before { create(:like, user: user, movie: movie) }

      it 'allows the like' do
        like2 = build(:like, user: user2, movie: movie)
        expect(like2).to be_valid
      end
    end

    context 'when same user likes different movies' do
      let(:movie2) { create(:movie) }

      before { create(:like, user: user, movie: movie) }

      it 'allows the like' do
        like2 = build(:like, user: user, movie: movie2)
        expect(like2).to be_valid
      end
    end
  end

  describe 'counter cache' do
    let(:movie) { create(:movie, likes_count: 0) }
    let(:user) { create(:user) }

    it 'increments movie likes_count when created' do
      expect { create(:like, user: user, movie: movie) }
        .to change { movie.reload.likes_count }.from(0).to(1)
    end

    it 'decrements movie likes_count when destroyed' do
      like = create(:like, user: user, movie: movie)

      expect { like.destroy }
        .to change { movie.reload.likes_count }.from(1).to(0)
    end
  end
end
