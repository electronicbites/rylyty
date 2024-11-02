class DownloadController < ApplicationController
  include BetaDownloadHelper
  before_filter :require_download_link

  def get_beta
    @download_url = if request.env['X_MOBILE_DEVICE']
      beta_app_iphone_install_uri download_manifest_beta_app_url(sha: params[:sha])
    else
      log_download!
      beta_app_software_package_url
    end

    if (params[:direct].present?)
      render 'download', cache_control: 'no-cache', layout: 'invitation'
    else
      @timeout = (params[:delay].presence || 5).to_i
      render 'hidden_download', cache_control: 'no-cache', layout: false
    end
  end

  def get_beta_manifest
    log_download!
    render 'manifest.plist', content_type: 'binary/octet-stream', cache_control: 'no-cache', layout: false
  end

private

  def require_download_link
    @download_link = DownloadLink.find_by_sha(params[:sha])
    if !@download_link
      render text: 'invalid token', status: :forbidden
      return false
    end

    if @download_link.limit_reached?
      render text: 'limit exceeded', status: :forbidden
      return false
    end
  end

  def log_download!
    Download.create(
      download_link: @download_link,
      client_ip: request.env['REMOTE_ADDR'],
      user_agent: request.env['HTTP_USER_AGENT'],
      udid: 'TODO'
    )
  end

end
