require 'spec_helper'

I18n.locale = 'de'

describe HomeController do

  describe '#index' do
    render_views

    it 'should be successfull' do
      get 'index'
      response.should be_success
    end

    it 'should should show welcome message' do
      get 'index'
      response.body.should include 'Betatest'
    end
  end

  describe 'impressum' do
    render_views

    it 'should be successfull' do
      get 'impressum'
      response.should be_success
    end
  end
end
