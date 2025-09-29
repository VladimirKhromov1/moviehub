# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Genre, type: :model do
  describe 'validations' do
    subject { build(:genre) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:tmdb_id).allow_nil }
  end

  describe 'associations' do
    it { is_expected.to have_many(:movie_genres).dependent(:destroy) }
    it { is_expected.to have_many(:movies).through(:movie_genres) }
  end


  describe 'uniqueness' do
    let!(:existing_genre) { create(:genre, name: 'Unique Genre') }

    it 'prevents duplicate genre names' do
      duplicate_genre = build(:genre, name: 'Unique Genre')
      expect(duplicate_genre).not_to be_valid
      expect(duplicate_genre.errors[:name]).to include('has already been taken')
    end

    it 'allows nil tmdb_id' do
      genre = build(:genre, tmdb_id: nil)
      expect(genre).to be_valid
    end

    context "when present" do
      before { existing_genre.update(tmdb_id: 123) }

      it 'prevents duplicate tmdb_id' do
        duplicate_genre = build(:genre, tmdb_id: 123)

        expect(duplicate_genre).not_to be_valid
        expect(duplicate_genre.errors[:tmdb_id]).to include('has already been taken')
      end
    end
  end
end
