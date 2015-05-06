require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  it { is_expected.to have_many(:reviews).dependent(:destroy) }

  it 'is not valid with a name of less than 3 characters' do
    restaurant = Restaurant.new name: 'kf'
    expect(restaurant).to have(1).error_on :name
    expect(restaurant).not_to be_valid
  end

  it 'is not valid unless it has a unique name' do
    Restaurant.create name: "Moe's Tavern"
    restaurant = Restaurant.new name: "Moe's Tavern"
    expect(restaurant).to have(1).error_on :name
  end

  describe '#average_rating' do
    context 'no reviews' do
      it "returns 'N/A' when there are no reviews" do
        restaurant = Restaurant.create(name: 'The Ivy')
        expect(restaurant.average_rating).to eq 'N/A'
      end
    end
  end

end
