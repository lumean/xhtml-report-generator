# expands the path relative to location of THIS file
require File.expand_path("../lib/xhtml_report_generator/version", __FILE__)


Gem::Specification.new do |s|
  s.name        = 'xhtml_report_generator'
  s.version     = '0.0.0'
  s.date        = '2014-11-10'
  s.summary     = "A simple and quick xhtml report generator"
  s.description = "be a bit more verbose"
  s.authors     = ["Manuel Widmer"]
  s.email       = 'm-widmer@gmx.ch'
  s.files       = ["lib/hrg.rb"]
  s.homepage    = 'http://rubygems.org/gems/hrg'
  s.license     = 'MIT'

  # dependencies
  s.add_runtime_dependency 'builder', '~> 3.2'
  # is the same as spec.add_runtime_dependency 'library', ['>= 3.2.0', '< 4.0']
 
  
  
end