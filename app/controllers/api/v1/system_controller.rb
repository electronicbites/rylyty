class Api::V1::SystemController < Api::BaseController
  respond_to :json

  def info
    info = {timestamp: Time.now.to_i}
    if params[:version] == '0.9.0'
      info.merge!(news: 'Hello')
    end
    render json: info.to_json
  end
end

