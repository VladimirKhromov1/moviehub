# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ListItem, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user_list) }
    it { is_expected.to belong_to(:movie) }
  end

  describe 'creating list items' do
    let(:user_list) { create(:user_list) }
    let(:movie) { create(:movie) }

    it 'connects user_list and movie' do
      list_item = create(:list_item, user_list: user_list, movie: movie)

      expect(list_item.user_list).to eq(user_list)
      expect(list_item.movie).to eq(movie)
      expect(user_list.movies).to include(movie)
    end

    it 'allows same movie in different lists' do
      user = create(:user)
      list1 = create(:user_list, user: user, name: 'List 1')
      list2 = create(:user_list, user: user, name: 'List 2')

      list_item1 = create(:list_item, user_list: list1, movie: movie)
      list_item2 = create(:list_item, user_list: list2, movie: movie)

      expect(list_item1).to be_valid
      expect(list_item2).to be_valid
    end

    it 'allows different movies in same list' do
      movie2 = create(:movie)

      list_item1 = create(:list_item, user_list: user_list, movie: movie)
      list_item2 = create(:list_item, user_list: user_list, movie: movie2)

      expect(list_item1).to be_valid
      expect(list_item2).to be_valid
      expect(user_list.movies).to include(movie, movie2)
    end
  end
end
