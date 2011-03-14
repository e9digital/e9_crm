# -*- encoding: utf-8 -*-
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
  s.add_dependency("inherited_resources", "~> 1.1.2")
  s.add_dependency("has_scope")
  s.add_dependency("inherited_resources_views")
  s.add_dependency("money")
  s.add_dependency("e9_rails", "~> 0.0.4")
  s.add_dependency("will_paginate")
end
