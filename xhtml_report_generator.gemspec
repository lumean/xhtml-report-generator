# expands the path relative to location of THIS file
require File.expand_path("../lib/xhtml_report_generator/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'xhtml_report_generator'
  s.version     = XhtmlReportGenerator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "A simple and quick xhtml report generator"


  s.description = <<-HEREDOC.gsub(/^ {4}/, '')
    Here is an example usage:
    @example Basic Testreport
      gen1 = XhtmlReportGenerator::Generator.new
      gen1.createLayout
      gen1.setTitle("Example Report")
      gen1.heading("titel", "h1", :btoc)
      gen1.heading("subtitel", "h2", :ltoc)
      gen1.heading("section", "h3")
      gen1.content("content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>", {"class"=>"bold"})
      gen1.html("<p class="italic">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")
    
    The javascript to render the table of contents, the custom generator functions and style sheet all can be
    supplied by your own, if needed.
  HEREDOC

  s.authors      = ["Manuel Widmer"]
  s.email        = 'm-widmer@gmx.ch'
  s.files        = Dir["{lib}/**/*.*", "LICENSE", "*.md"]
  s.require_path = 'lib'
  s.homepage    = 'http://rubygems.org/gems/hrg'
  s.license     = 'MIT'

  # dependencies
  # s.add_runtime_dependency 'builder', '~> 3.2'
  # is the same as spec.add_runtime_dependency 'library', ['>= 3.2.0', '< 4.0']
 
  
end