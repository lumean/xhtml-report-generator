# encoding: utf-8
require 'rexml/document'
require 'rexml/formatters/transitive'

require_relative 'version'

module XhtmlReportGenerator

  # This is the main generator class. It can be instanced with custom javascript, css, and ruby files to allow
  # generation of arbitrary reports.
  class Generator
    attr_accessor :document, :file
    # @param opts [Hash] See the example for an explanation of the valid symbols
    # @example Valid symbols for the opts Hash
    #   :title        Title in the header section, defaults to "Title"
    #   :js           if specified, array of javascript files which are inlined into the html header section
    #   :css          if specified, array of css files which are inlined into the html header section
    #   :css_print    if specified, array of css files which are inlined into the html header section with media=print
    #   :custom_rb    if specified, path to a custom Module containing all the logic to create content for the report
    #                 see (custom.rb) on how to write it. As a last statement you should extend your module name
    #                 outside of the module definition.
    #   :sync         if true, all changes are immediately written to disk
    def initialize(opts = {})
      # define the default values
      resources = File.expand_path("../../resource/", __FILE__)
      defaults = {
        :title     => "Title",
        :js        => [
            File.expand_path("jquery-3.2.1.min.js", resources),
            File.expand_path("d3v3.5.17/d3.min.js", resources),
            File.expand_path("c3v0.4.18/c3.min.js", resources),
            File.expand_path("split.min.js", resources),
            File.expand_path("toc_full.js", resources),
          ],
        :css       => [
            File.expand_path("css/style.css", resources)
            File.expand_path("c3v0.4.18/c3.min.css", resources)
          ],
        :css_print => [
            File.expand_path("css/print.css", resources)
          ],
        :custom_rb => File.expand_path("../custom.rb", __FILE__),
        :sync => false,
      }

      opts[:title]      = defaults[:title]     if !opts.key?(:title)
      opts[:js]         = defaults[:js]        if !opts.key?(:js)
      opts[:css]        = defaults[:css]       if !opts.key?(:css)
      opts[:css_print]  = defaults[:css_print] if !opts.key?(:css_print)
      opts[:custom_rb]  = defaults[:custom_rb] if !opts.key?(:custom_rb)

      # load the custom module and extend it, use instance_eval otherwise the module will affect
      # all existing Generator classes
      instance_eval(File.read(opts[:custom_rb]), opts[:custom_rb])

      @document = Generator.create_xhtml_document(opts[:title])
      head = @document.elements["//head"]

      head.add_element("meta", {"charset" => "utf-8"})

      # insert css
      opts[:css].each do |css_path|
        style = head.add_element("style", {"type" => "text/css"})
        cdata(File.read(css_path), style)
      end

      # insert css for printing
      opts[:css_print].each do |css_path|
        style = head.add_element("style", {"type" => "text/css", "media"=>"print"})
        cdata(File.read(css_path), style)
      end

      # inster js files
      opts[:js].each do |js_path|
        script = head.add_element("script", {"type" => "text/javascript"})
        cdata(File.read(js_path), script)
      end

    end

    # Surrounds CData tag with c-style comments to remain compatible with normal html.
    # For plain xhtml documents this is not needed.
    # Example /*<![CDATA[*/\n ...content ... \n/*]]>*/
    # @param str [String] the string to be enclosed in cdata
    # @param parent_element [REXML::Element] the element to which cdata should be added
    # @return [String] CDATA enclosed in c-style comments /**/
    def cdata(str, parent_element)
      f = REXML::Formatters::Transitive.new(0) # use Transitive to preserve source formatting
      # somehow there is a problem with CDATA, any text added after will automatically go into the CDATA
      # so we have do add a dummy node after the CDATA and then add the text.
      parent_element.add_text("/*")
      parent_element.add(REXML::CData.new("*/\n"+str+"\n/*"))
      parent_element.add(REXML::Comment.new("dummy comment to make c-style comments for cdata work"))
      parent_element.add_text("*/")
    end

    # Check if the give string is a valid UTF-8 byte sequence. If it is not valid UTF-8, then
    # all invalid bytes are replaced by "\u2e2e" (\xe2\xb8\xae) ('REVERSED QUESTION MARK') because the default
    # replacement character "\uFFFD" ('QUESTION MARK IN DIAMOND BOX') is two slots wide and might
    # destroy mono spaced formatting
    # @param str [String] of any encoding
    # @return [String] UTF-8 encoded valid string
    def encoding_fixer(str)
      #if !str.force_encoding('UTF-8').valid_encoding?
      #  str.encode!('UTF-8', 'ISO-8859-1', {:invalid => :replace, :undef => :replace, :xml => :text})
      #end
      tmp = str.force_encoding('UTF-8').encode('UTF-8',{:invalid => :replace, :undef => :replace, :replace => "\u2e2e"})
      # replace all special control chars as well but keep newline and whitespace "\u2e2e"
      tmp.force_encoding('binary').gsub!(/[\x00-\x07\x0C-\x1F]|\xef\xbf\xbe|\xef\xbf\xbf/n, "\xe2\xb8\xae".force_encoding('binary'))
      return tmp.force_encoding('UTF-8')
    end

    # Creates a minimal valid xhtml document including header title and body elements
    # @param title [String] Title in the header section
    def self.create_xhtml_document(title)
      # don't use version 1.1 - firefox has not yet a parser vor xml 1.1
      # https://bugzilla.mozilla.org/show_bug.cgi?id=233154
      header = '<?xml version="1.0" encoding="UTF-8"?>'
      # change of doctype to <!DOCTYPE html> for html5 compatibility
      header << '<!DOCTYPE html>'

      doc = REXML::Document.new(header)
      html = doc.add_element("html", {"xmlns" => "http://www.w3.org/1999/xhtml"})
      # create header
      head = html.add_element("head")
      t = head.add_element("title")
      t.text = title
      html.add_element("body")
      return doc
    end

    # returns the string representation of the xml document
    # @param indent [Number] indent for child elements. defaults to 0.
    #                        Note: if you change the indet this might destroy formatting of <pre> sections
    # @return [String] formatted xml document
    def to_s(indent = 0)
      output = ""
      # note :  transitive is needed to preserve newlines in <pre> tags
      # note2:  the hash options syntax is supported only from ruby version >= 2.0.0 we need the old style
      #         for compatibility with 1.9.3
      # @document.write({:output=>output, :indent=>indent, :transitive=>true})
      # change to Formatters since document.write is deprecated
      f = REXML::Formatters::Transitive.new(indent)
      f.write(@document, output)
      return output
    end

    # Saves the xml document to a file. If no file is given, the file which was used most recently for this Generator
    # object will be overwritten.
    # @param file [String] absolute or relative path to the file to which will be written. Default: last file used.
    # @param mode [String] defaults to 'w', one of the file open modes that allows writing ['r+','w','w+','a','a+']
    def write(file=@file, mode='w')
      # instance variables are nil if they were never initialized
      if file == nil
        raise "no valid file given"
      end
      @file = file
      File.open(file, "#{mode}:UTF-8") {|f| f.write(self.to_s.force_encoding(Encoding::UTF_8))}
    end

  end
end
