#    logfile.title("mein title")
#    logfile.section
#    logfil.content("mein resultat")
#    logfile.markup(regexstart, regex end,  :yellow)
require 'rexml/document'

module XhtmlReportGenerator
  class Generator
    # @param opts [Hash]
    #   :jquery       if specified, path to a version of jquery, that will be inlined into the html header section
    #   :toc          if specified, path to a javascript.js.rb file that contains the magic to generate all
    #   :css          if specified, path to a css file that contains the markup rules for your generated reports
    #   :custom_rb    if specified, path to a custom Module containing
    def initialize(opts = {})
      # define the default values
      path = File.expand_path("../xhtml_report_generator", __FILE__)
      symbols = {
        :jquery => File.expand_path("jquery.js",path),
        :toc => File.expand_path("toc.js",path),
        :css => File.expand_path("style_template.css",path),
        :custom_rb => File.expand_path("custom.rb",path)
      }
      # either use the default files provided with the gem, or those provided by the caller
      symbols = symbols.merge(opts)
      for key in symbols.keys do
        # read the contents into the symbols hash
        symbols[key] = File.read(symbols[key])
      end
      # load the custom module and extend it, use instance_eval otherwise the module will affect
      # all existing Generator classes
      instance_eval symbols[:custom_rb]
      @document = REXML::Document.new(self.header)
    end

    def code(mystring)
    end

    def write
    end

    def to_s
      output = ""
      @document.write(:output=>output,:indent=>2)
      return output
    end

    def writeToFile(file, mode='w')
      File.open(file, "#{mode}:UTF-8") {|f| f.write(self.to_s)}
    end
  end
end

gen1 = XhtmlReportGenerator::Generator.new
puts gen1.to_s()
#
gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "lib/xhtml_report_generator/custom2.rb")
puts gen2.to_s()

puts gen1.to_s()
#recurse_constants(XhtmlReportGenerator)

#puts XhtmlReportGenerator.constants()
