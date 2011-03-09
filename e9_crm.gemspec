$:.push File.expand_path("../lib", __FILE__)
require "e9_crm/version"

Gem::Specification.new do |s|
  s.name        = "e9_crm"
  s.version     = E9Crm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.summary     = "CRM engine plugin for the e9 CMS"
  s.email       = "travis@e9digital.com"
  s.homepage    = "http://www.e9digital.com"
  s.description = ""
  s.authors     = ['Travis Cox']

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency("rails", "~> 3.0.0")
end
