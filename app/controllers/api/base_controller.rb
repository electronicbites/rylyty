class Api::BaseController < ApplicationController
  respond_to :json
  skip_before_filter  :verify_authenticity_token
  before_filter :set_locale

  # this is weired! the default locale is set to de, but in the rabl views the english translation is 
  # is requested. this is just a temporary hack!!!
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  ##
  # responde with a unified json message:
  #     {"success":false,"message":"Record Not Found"}
  # default http code 404
  #
  # When calles with an *Error* the Error's message will
  # be used for the json's `message` key
  #
  # @param [Hash|Error] Optional overwrites the JSON response
  #
  # @example
  #    record_not_found status: 409, message: "This thing is already present."
  #    record_not_found "This game does not exist"
  def record_not_found(env = nil)
    rspd = {
      json: {success: false, message: "Record Not Found"},
      status: 404
    }

    if env.respond_to?(:message)
      rspd[:message] = env.message
    elsif env.is_a? String
      rspd[:message] = env
    elsif env.respond_to?(:to_hash)
      env = env.to_hash
      status = env.delete :status
      rspd[:status] = status if status
      rspd[:json].merge! env
    end if env

    render rspd
  end
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
end