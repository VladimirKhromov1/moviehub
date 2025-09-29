# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
    it { is_expected.to validate_length_of(:password).is_at_least(6) }

    it 'validates email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    context 'when updating existing user' do
      let(:user) { create(:user) }

      it 'does not require password' do
        user.email = 'new@example.com'
        expect(user).to be_valid
      end

      it 'requires password if password is being changed' do
        user.password = 'short'
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
      end
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:likes).dependent(:destroy) }
    it { is_expected.to have_many(:liked_movies).through(:likes).source(:movie) }
    it { is_expected.to have_many(:user_lists).dependent(:destroy) }
  end

  describe 'callbacks' do
    describe 'before_save' do
      context 'when email contains uppercase letters' do
        let(:user) { build(:user, email: 'TEST@EXAMPLE.COM') }

        it 'downcases email before saving' do
          user.save
          expect(user.email).to eq('test@example.com')
        end
      end
    end

    describe 'after_create' do
      it 'creates default lists' do
        expect { create(:user) }.to change(UserList, :count).by(2)
      end

      context 'when user is created' do
        let(:user) { create(:user) }

        it 'creates watchlist' do
          expect(user.user_lists.pluck(:name)).to include('Want to Watch')
        end

        it 'creates favorites list' do
          expect(user.user_lists.pluck(:name)).to include('Favorites')
        end
      end
    end
  end

  describe '#liked?' do
    let(:user) { create(:user) }
    let(:movie) { create(:movie) }

    context 'when user has liked the movie' do
      before { create(:like, user: user, movie: movie) }

      it 'returns true' do
        expect(user.liked?(movie)).to be true
      end
    end

    context 'when user has not liked the movie' do
      it 'returns false' do
        expect(user.liked?(movie)).to be false
      end
    end
  end

  describe '#watchlist' do
    let(:user) { create(:user) }

    it 'returns the watchlist' do
      watchlist = user.watchlist
      expect(watchlist).to be_present
      expect(watchlist.name).to eq('Want to Watch')
    end
  end

  describe '#favorites' do
    let(:user) { create(:user) }

    it 'returns the favorites list' do
      favorites = user.favorites
      expect(favorites).to be_present
      expect(favorites.name).to eq('Favorites')
    end
  end

  describe '.DEFAULT_LISTS' do
    it 'contains correct default lists' do
      expect(User::DEFAULT_LISTS).to eq({
        watchlist: 'Want to Watch',
        favorites: 'Favorites'
      })
    end
  end

  describe 'password encryption' do
    let(:user) { create(:user, password: 'test_password', password_confirmation: 'test_password') }

    it 'encrypts the password' do
      expect(user.password_digest).to be_present
      expect(user.password_digest).not_to eq('test_password')
    end

    it 'authenticates with correct password' do
      expect(user.authenticate('test_password')).to eq(user)
    end

    it 'does not authenticate with incorrect password' do
      expect(user.authenticate('wrong_password')).to be false
    end
  end
end
