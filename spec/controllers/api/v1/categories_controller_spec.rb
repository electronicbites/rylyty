require 'spec_helper'

describe Api::V1::CategoriesController do
  render_views

  describe '#get index' do
    let(:category) { FactoryGirl.create(:tag) }

    it 'should contain key categories' do
      get :index, format: :json
      parse_json.should have_key 'categories'
    end

    it 'should contain categories' do
      category
      get :index, format: :json
      parse_json['categories'].first.should have_key 'value' 
    end
  end
end
