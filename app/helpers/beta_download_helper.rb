module BetaDownloadHelper

  # for more informations on AWS::S3 see:
  # http://docs.amazonwebservices.com/AWSRubySDK/latest/AWS/S3/S3Object.html#url_for-instance_method#url_for-instance_method

  def aws_bucket
    return @bucket if @bucket
    s3 = AWS::S3.new
    @bucket = s3.buckets["rylyty-#{Rails.env}"]
  end

  # def beta_app_manifest_url

  #   aws_bucket.objects['versions/manifest.plist'].url_for(:read, expires: 60).to_s
  # end

  def beta_app_bundle_vesion
    '1.0'
  end

  def beta_app_software_package_url
    aws_bucket.objects['versions/rylyty.ipa'].url_for(:read, expires: 60).to_s
  end

  def beta_app_display_image_url
    aws_bucket.objects['versions/app-icon.png'].url_for(:read, expires: 60).to_s
  end

  def beta_app_full_size_image_url
    aws_bucket.objects['versions/appstorepic.jpg'].url_for(:read, expires: 60).to_s
  end

  def beta_app_iphone_install_uri(manifest_url)
    "itms-services://?action=download-manifest&url=#{manifest_url}"
  end

end