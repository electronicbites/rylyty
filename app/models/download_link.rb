class DownloadLink < ActiveRecord::Base

  has_many :downloads
  has_many :invitations, :dependent => :destroy

  attr_accessible :url, :bundle, :num_downloads

  validates :url, presence: true, immutable: true, format: { with: /:sha/, message: "is expected with :sha -placeholder f.ex. http://test.dev/:sha" }
  validates :sha, presence: true, immutable: true, uniqueness: true
  validates :bundle, allow_nil: true, immutable: true
  validates :num_downloads, presence: true

  # sha is generated at creation time (friendly_tokenirst save only)
  before_validation do |download_link|
    download_link.sha = Devise.friendly_token if download_link.sha.nil?
  end

  after_initialize :default_values

  def generate_url(params=nil)
    url.sub(/:sha/, sha) + (params ? "?#{Rack::Utils.build_query(params)}" : '')
  end

  def limit_reached?
    num_dlds = Download.where(download_link_id: self.id).count
    num_dlds >= self.num_downloads
  end

  def to_s
    "#{bundle}:#{created_at.strftime("%Y-%m-%d")}:#{sha}"
  end

  def self.export_csv(file_path, bundle = nil, enc = "\"", sep = ",")
    if file_path.is_a?(Pathname)
      csv_file_path = file_path
    else
      csv_file_path = Pathname.new(file_path)
    end
    csv_file_path.delete if csv_file_path.exist?

    File.open(csv_file_path, 'w') do |file|
      file.write("num_downloads#{sep}url\n")
      (bundle.nil? ? DownloadLink.all : DownloadLink.where(bundle: bundle)).each do |download_link|
        file.write("#{download_link.num_downloads}#{sep}#{enc}#{download_link.generate_url.gsub(Regexp.new(enc), "\\#{enc}")}#{enc}\n")
      end
    end
  end


  def default_values
    self.url ||= Rails.application.routes.url_helpers.download_beta_app_url(Rails.application.config.action_mailer.default_url_options.merge(sha: ':sha'))
  end
end
