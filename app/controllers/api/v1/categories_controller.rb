class Api::V1::CategoriesController < ApplicationController
  def index
    @categories = Tag.all
  end
end
