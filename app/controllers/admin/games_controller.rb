class Admin::GamesController < ApplicationController
  #FIXME _only admins should be able to call this
  layout 'admin'
  def edit
    @game = Game.find params[:id]
  end

  def update
    @game = Game.find params[:game][:id]
    @game.image = params[:game][:image]
    @game.save!
  end
end