Gem::Specification.new do |s|
  require File.expand_path("../version", __FILE__)
  
  s.name = "sandbox"
  s.summary = "api interface"
  s.description = "sic!"
  s.files = Dir["{app,lib,config}/**/*"] + ["MIT-LICENSE", "Gemfile", "README.md"]
  s.version = Sandbox::VERSION
end
