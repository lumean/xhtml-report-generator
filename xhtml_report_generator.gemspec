# expands the path relative to location of THIS file
require_relative 'lib/xhtml_report_generator'

Gem::Specification.new do |s|
  s.name        = 'xhtml_report_generator'
  s.version     = XhtmlReportGenerator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = Time.now.strftime("%Y-%m-%d")
  s.summary     = "A simple html or xhtml generator or logger to create human readable reports and logs"
  s.required_ruby_version = '>= 2.0.0'

  s.description = <<-HEREDOC.gsub(/^ {4}/, '')
    The generator can be used to create html or xhtml files. It comes with many utility functions.

    The javascript to render the table of contents, the custom generator functions and style sheet all can be
    supplied by your own, if necessary. By default there are methods to insert tables, links, paragraphs, preformatted text
    and arbitrary xhtml code. Due to the xml nature it is also easy to insert SVG graphs / pictures.

    Checkout the github project to see some examples.
  HEREDOC

  s.authors      = ["Manuel Widmer"]
  s.email        = 'm-widmer@gmx.ch'
  s.files        = Dir["{lib}/**/*.rb",
                      "LICENSE",
                      "*.md",
                      "resource/c3v0.4.18/*",
                      "resource/d3v3.5.17/*",
                      "resource/css/*.css",
                      "resource/js/*.js",
                  ]
  s.require_path = 'lib'
  s.homepage    = 'https://rubygems.org/gems/xhtml_report_generator'
  s.license     = 'MIT'

  # dependencies
  # s.add_runtime_dependency 'builder', '~> 3.2'
  # s.add_runtime_dependency 'imagesize', '>= 0.1.1'
  # is the same as spec.add_runtime_dependency 'library', ['>= 3.2.0', '< 4.0']

end
