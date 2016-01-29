# encoding: utf-8
require 'rexml/document'
require 'rexml/formatters/transitive'

module XhtmlReportGenerator
  
  # This is the main generator class. It can be instanced with custom javascript, css, and ruby files to allow
  # generation of arbitrary reports.
  class Generator
    attr_accessor :document, :file
    # @param opts [Hash] See the example for an explanation of the valid symbols
    # @example Valid symbols for the opts Hash
    #   :jquery       if specified, path to a version of jquery, that will be inlined into the html header section
    #   :toc          if specified, path to a javascript.js.rb file that contains the magic to generate all
    #   :css          if specified, path to a css file that contains the markup rules for your generated reports
    #   :css_print    if specified, path to a css file that contains the markup rules for printing the report
    #   :custom_rb    if specified, path to a custom Module containing
    def initialize(opts = {})
      # define the default values
      path = File.expand_path("../xhtml_report_generator", __FILE__)
      symbols = {
        :jquery    => File.expand_path("jquery.js",path),
        :toc       => File.expand_path("toc.js",path),
        :css       => File.expand_path("style_template.css",path),
        :css_print => File.expand_path("print_template.css",path),
        :custom_rb => File.expand_path("custom.rb",path)
      }
      # either use the default files provided with the gem, or those provided by the caller
      symbols = symbols.merge(opts)
      custom_rb_path = symbols[:custom_rb]
      for key in symbols.keys do
        # read the contents into the symbols hash
        symbols[key] = File.read(symbols[key])
      end
      # load the custom module and extend it, use instance_eval otherwise the module will affect
      # all existing Generator classes
      instance_eval(symbols[:custom_rb], custom_rb_path)

      @document = Generator.create_xhtml_document("Title")
      head = @document.elements["//head"]
      
      head.add_element("meta", {"charset" => "utf-8"})
      
      # insert the custom css, and javascript files
      style = head.add_element("style", {"type" => "text/css"})
      cdata(symbols[:css], style)
        
      style = head.add_element("style", {"type" => "text/css", "media"=>"print"})
      cdata(symbols[:css_print], style)

      script = head.add_element("script", {"type" => "text/javascript"})
      cdata(symbols[:jquery], script)

      script = head.add_element("script", {"type" => "text/javascript"})
      cdata(symbols[:toc], script)
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
      # so we prepare the CDATA manually and add the text as raw.
      #out = "/*"
      #f.write(REXML::CData.new("*/\n"+str+"\n"), out)
      #out << "*/"
      #t = REXML::Text.new(out, true, nil, true)
      #parent_element.add(t)
      parent_element.add_text("/*")
      parent_element.add(REXML::CData.new("*/\n"+str+"\n/*"))
      parent_element.add(REXML::Comment.new("dummy comment to make c-style comments for cdata work"))
      parent_element.add_text("*/")
    end
    
    # Check if the give string is a valid UTF-8 byte sequence.
    # If it is not valid UTF-8, then assumes the source encoding to be ISO-8859-1 
    # and converts to UTF-8
    # @param str [String] of any encoding
    # @return [String] UTF-8 encoded valid string
    def encoding_fixer(str)
      #if !str.force_encoding('UTF-8').valid_encoding?
      #  str.encode!('UTF-8', 'ISO-8859-1', {:invalid => :replace, :undef => :replace, :xml => :text})
      #end
      tmp = str.force_encoding('UTF-8').encode('UTF-8',{:invalid => :replace, :undef => :replace})
      # replace all special control chars as well but keep newline and whitespace
      tmp.gsub!(/[\u0000-\u0007\u000C-\u001F]|\xef\xbf\xbe|\xef\xbf\xbf/, "\uFFFD")
      
      if tmp.match(/\x00/)
        puts "jklajsljflkjlk"
      end
      return tmp
    end

    # Creates a minimal valid xhtml document including header title and body elements
    # @param title [String] Title in the header section
    def self.create_xhtml_document(title)
      # don't use version 1.1 - firefox has not yet a parser vor xml 1.1
      # https://bugzilla.mozilla.org/show_bug.cgi?id=233154
      header = '<?xml version="1.0" encoding="UTF-8"?>'
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



