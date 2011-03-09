$:.push File.expand_path("../lib", __FILE__)
require "e9_crm/version"

Gem::Specification.new do |s|
  s.name        = "e9_crm"
  s.version     = E9Crm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = ""
  s.email       = "travis@e9digital.com"
  s.homepage    = "http://www.e9digital.com"
  s.description = ""
  s.authors     = ['Travis Cox']

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency("responders", "~> 0.6.0")
  s.add_dependency("has_scope",  "~> 0.5.0")
end
