require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/support/fixtures/vcr_cassettes'
  c.hook_into :faraday
  c.ignore_localhost = false
  c.preserve_exact_body_bytes do |http_message|
    http_message.headers['Content-Type'].to_a.any?{|ct| ct =~ /^(image|binary)\//}
  end
end