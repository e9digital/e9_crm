# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "e9_crm/version"

Gem::Specification.new do |s|
  s.name        = "e9_crm"
  s.version     = E9Crm::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.email       = "travis@e9digital.com"
  s.homepage    = "http://www.e9digital.com"
  s.summary     = "CRM engine plugin for the e9 CMS"
  s.description = File.open('README.md').read rescue nil
  s.authors     = ['Travis Cox']

  s.rubyforge_project = "e9_crm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("money")
  s.add_dependency("kramdown", "~> 0.13")
end
