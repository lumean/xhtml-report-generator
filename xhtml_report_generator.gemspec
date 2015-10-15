# expands the path relative to location of THIS file
require File.expand_path("../lib/xhtml_report_generator/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'xhtml_report_generator'
  s.version     = XhtmlReportGenerator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "A simple and quick xhtml report generator"
  s.required_ruby_version = '>= 1.9.3'

  s.description = <<-HEREDOC.gsub(/^ {4}/, '')
    The generator can be used to create xhtml files. It comes with some default utility functions.
    == Here is an example usage
      gen1 = XhtmlReportGenerator::Generator.new
      gen1.create_layout("Title")
      gen1.heading("h1", {"class" => "bothtoc"}) {"titel"}
      gen1.heading("h2") {"subtitel"}
      gen1.heading("h3") {"section"}
      gen1.content({"class"=>"bold"}) {"content function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>"}
      gen1.html("&lt;p class=\"italic\">html function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>&lt;/p>")
      gen1.highlight(/Ha.*lt/)
      
    The javascript to render the table of contents, the custom generator functions and style sheet all can be
    supplied by your own, if necessary. 
  HEREDOC

  s.authors      = ["Manuel Widmer"]
  s.email        = 'm-widmer@gmx.ch'
  s.files        = Dir["{lib}/**/*.*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.homepage    = 'https://rubygems.org/gems/xhtml_report_generator'
  s.license     = 'MIT'

  # dependencies
  # s.add_runtime_dependency 'builder', '~> 3.2'
  # s.add_runtime_dependency 'imagesize', '>= 0.1.1'
  # is the same as spec.add_runtime_dependency 'library', ['>= 3.2.0', '< 4.0']
  
end