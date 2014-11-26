#    logfile.title("mein title")
#    logfile.section
#    logfil.content("mein resultat")
#    logfile.markup(regexstart, regex end,  :yellow)
require 'rexml/document'

module XhtmlReportGenerator
  class Generator
    attr_accessor :document
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

      @document = Generator.createXhtml("Title")
      head = @document.elements["//head"]
      # insert the custom css, and javascript files
      style = head.add_element("style", {"type" => "text/css"})
      # remove all newlines
      style.add_text(REXML::CData.new("\n"+symbols[:css].gsub(/\n/, "")+"\n"))

      script = head.add_element("script", {"type" => "text/javascript"})
      script.add_text(REXML::CData.new("\n"+symbols[:jquery]+"\n"))

      script = head.add_element("script", {"type" => "text/javascript"})
      script.add_text(REXML::CData.new("\n"+symbols[:toc]+"\n"))
    end

    # Creates a minimal valid xhtml document including header title and body elements
    # @param title [String] Title in the header section
    def self.createXhtml(title)
      header = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'
      header += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'

      doc = REXML::Document.new(header)
      html = doc.add_element("html", {"xmlns" => "http://www.w3.org/1999/xhtml"})
      # create header
      head = html.add_element("head")
      t = head.add_element("title")
      t.text = title
      html.add_element("body")
      return doc
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



