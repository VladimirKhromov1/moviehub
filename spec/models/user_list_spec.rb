# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserList, type: :model do
  describe 'validations' do
    subject { build(:user_list) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:list_items).dependent(:destroy) }
    it { is_expected.to have_many(:movies).through(:list_items) }
  end

  describe 'user integration' do
    context 'when creating multiple lists' do
      let(:user) { create(:user) }

      it 'allows multiple lists per user' do
        list1 = create(:user_list, user: user, name: 'Test List 1')
        list2 = create(:user_list, user: user, name: 'Test List 2')

        expect(user.user_lists).to include(list1, list2)
        expect(user.user_lists.count).to eq(4) # 2 default lists + 2 custom lists
      end

      it 'allows different names for lists' do
        watchlist = create(:user_list, user: user, name: 'Test Watchlist')
        favorites = create(:user_list, user: user, name: 'Test Favorites')

        expect(user.user_lists).to include(watchlist, favorites)
        expect(user.user_lists.pluck(:name)).to include('Test Watchlist', 'Test Favorites')
      end
    end

    context 'when user is destroyed' do
      let(:user) { create(:user) }
      let!(:user_list) { create(:user_list, user: user) }

      it 'destroys associated user_lists' do
        expect { user.destroy }.to change(UserList, :count).by(-3) # 1 custom list + 2 default lists
      end

      it 'removes user_list from database' do
        user_list_id = user_list.id
        user.destroy

        expect(UserList.find_by(id: user_list_id)).to be_nil
      end
    end
  end

  describe 'movie associations' do
    let(:user_list) { create(:user_list) }
    let(:movie) { create(:movie) }

    context 'when adding movies' do
      it 'can add movies through list_items' do
        create(:list_item, user_list: user_list, movie: movie)

        expect(user_list.movies).to include(movie)
        expect(user_list.list_items.count).to eq(1)
      end

      it 'can add multiple movies' do
        movie2 = create(:movie)
        create(:list_item, user_list: user_list, movie: movie)
        create(:list_item, user_list: user_list, movie: movie2)

        expect(user_list.movies).to include(movie, movie2)
        expect(user_list.movies.count).to eq(2)
      end

      it 'allows same movie in different lists' do
        user = create(:user)
        list1 = create(:user_list, user: user, name: 'List 1')
        list2 = create(:user_list, user: user, name: 'List 2')

        create(:list_item, user_list: list1, movie: movie)
        create(:list_item, user_list: list2, movie: movie)

        expect(list1.movies).to include(movie)
        expect(list2.movies).to include(movie)
      end
    end

    context 'when user_list is destroyed' do
      let!(:list_item) { create(:list_item, user_list: user_list, movie: movie) }

      it 'destroys associated list_items' do
        expect { user_list.destroy }.to change(ListItem, :count).by(-1)
      end

      it 'removes list_item from database' do
        list_item_id = list_item.id
        user_list.destroy

        expect(ListItem.find_by(id: list_item_id)).to be_nil
      end

      it 'does not affect the movie' do
        expect { user_list.destroy }.not_to change(Movie, :count)
        expect(movie.reload).to be_persisted
      end
    end
  end

  describe 'factory' do
    it 'creates valid user_list' do
      user_list = create(:user_list)
      expect(user_list).to be_valid
      expect(user_list.name).to be_present
      expect(user_list.user).to be_present
    end

    it 'creates with custom name' do
      user_list = create(:user_list, name: 'Custom List')
      expect(user_list.name).to eq('Custom List')
    end
  end
end
