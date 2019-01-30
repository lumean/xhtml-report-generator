# encoding: utf-8
require 'rexml/document'
require 'rexml/formatters/transitive'
require 'base64'

module XhtmlReportGenerator

  VERSION = '4.0.2'

  # This is the main generator class. It can be instanced with custom javascript, css, and ruby files to allow
  # generation of arbitrary reports.
  # @attr [REXML::Document] document This is the html document / actual report
  # @attr [String] file path to the file where this report is saved to. Default: nil
  # @attr [Boolean] sync if true, the report will be written to disk after every modificaiton. Default: false
  #                 Note that sync = true can have severe performance impact, since the complete
  #                 html file is written to disk after each change.
  class Generator
    attr_accessor :document, :file, :sync
    # @param opts [Hash] See the example for an explanation of the valid symbols
    # @example Valid keys for the opts Hash
    #   :title        Title in the header section, defaults to "Title"
    #   :js           if specified, array of javascript files which are inlined into the html header section, after
    #                 the default included js files (check in sourcecode below).
    #   :css          if specified, array of css files which are inlined into the html header section after
    #                 the default included css files (check in sourcecode below).
    #   :css_print    if specified, array of css files which are inlined into the html header section with media=print
    #                 after the default included print css files (check in sourcecode below).
    def initialize(opts = {})
      # define the default values
      resources = File.expand_path("../../resource/", __FILE__)
      defaults = {
        :title     => "Title",
        :js        => [
            File.expand_path("js/jquery-3.2.1.min.js", resources),
            File.expand_path("d3v5.7.0/d3.min.js", resources),
            File.expand_path("c3v0.6.12/c3.min.js", resources),
            File.expand_path("js/split.min.js", resources),
            File.expand_path("js/layout_split.js", resources),
            File.expand_path("js/table_of_contents.js", resources),
            File.expand_path("js/toggle_linewrap.js", resources),
          ],
        :css       => [
            File.expand_path("css/style.css", resources),
            File.expand_path("c3v0.6.12/c3.min.css", resources),
          ],
        :css_print => [
            File.expand_path("css/print.css", resources)
          ],
        #:custom_rb => File.expand_path("../custom.rb", __FILE__),
      }
      @sync = false

      opts[:title]      = defaults[:title]     if !opts.key?(:title)

      if opts.key?(:js)
        opts[:js]         = defaults[:js] + opts[:js]
      else
        opts[:js]         = defaults[:js]
      end
      if opts.key?(:css)
        opts[:css]        = defaults[:css] + opts[:css]
      else
        opts[:css]        = defaults[:css]
      end
      if opts.key?(:css_print)
        opts[:css_print]  = defaults[:css_print] + opts[:css_print]
      else
        opts[:css_print]  = defaults[:css_print]
      end

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
      document_changed()
    end

    # Surrounds CData tag with c-style comments to remain compatible with normal html.
    # For plain xhtml documents this is not needed.
    # Example /*<![CDATA[*/\n ...content ... \n/*]]>*/
    # @param str [String] the string to be enclosed in cdata
    # @param parent_element [REXML::Element] the element to which cdata should be added
    # @return [REXML::Element] parent_element
    def cdata(str, parent_element)
      # sometimes depending on LC_CTYPE environemnt variable it can happen that js / css files are interpreted
      # with wrong encoding
      str = encoding_fixer(str)
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
      str = str.to_s  # catch str = nil
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
      # don't use version 1.1 - firefox has not yet a parser for xml 1.1
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
      if file.nil?
        raise "no valid file given: '#{file}'"
      end
      @file = file
      File.open(file, "#{mode}:UTF-8") {|f| f.write(self.to_s.force_encoding(Encoding::UTF_8))}
    end

    # This method should be called after every change to the document.
    # Here we ensure the report is written to disk after each change
    # if #sync is true. If #sync is false this method does nothing
    def document_changed()
      if @sync
        if @file.nil?
          raise "You must call #write at least once before you can enable synced mode"
        end
        write()
      end
    end

    # creates the basic page layout and sets the current Element to the main content area (middle div)
    # @example The middle div is matched by the following xPath
    #   //body/div[@id='middle']
    # @param title [String] the title of the document
    # @param layout [Fixnum] one of 0,1,2,3 where 0 means minimal layout without left and right table of contents,
    #   1 means only left toc, 2 means only right toc, and 3 means full layout with left and right toc.
    def create_layout(title, layout=3)
      raise "invalid layout selector, choose from 0..3" if (layout < 0) || (layout > 3)

      @body = @document.elements["//body"]
      # only add the layout if it is not already there
      if !@layout
        head = @body.add_element("div", {"class" => "head", "id" => "head"})
        head.add_element("button", {"id" => "pre_toggle_linewrap"}).add_text("Toggle Linewrap")

        if (layout & 0x1) != 0
        div = @body.add_element("div", {"class" => "lefttoc split split-horizontal", "id" => "ltoc"})
        div.add_text("Table of Contents")
        div.add_element("br")
        end

        @div_middle = @body.add_element("div", {"class" => "middle split split-horizontal", "id" => "middle"})

        if (layout & 0x2) != 0
        div = @body.add_element("div", {"class" => "righttoc split split-horizontal", "id" => "rtoc"})
        div.add_text("Quick Links")
        div.add_element("br");div.add_element("br")
        end

        @body.add_element("p", {"class" => "#{layout}", "id" => "layout"}).add_text("this text should be hidden")

        @layout = true
      end
      @current = @document.elements["//body/div[@id='middle']"]
      set_title(title)
      document_changed()
    end

    # sets the title of the document in the <head> section as well as in the layout header div
    # create_layout must be called before!
    # @param title [String] the text which will be insertead
    def set_title(title)
      if !@layout
        raise "call create_layout first"
      end
      pagetitle = @document.elements["//head/title"]
      pagetitle.text = title
      div = @document.elements["//body/div[@id='head']"]
      div.text = title
      document_changed()
    end

    # returns the title text of the report
    # @return [String] The title of the report
    def get_title()
      pagetitle = @document.elements["//head/title"]
      return pagetitle.text
    end

    # set the current element to the element or first element matched by the xpath expression.
    # The current element is the one which can be modified through highlighting.
    # @param xpath [REXML::Element|String] the element or an xpath string
    def set_current!(xpath)
      if xpath.is_a?(REXML::Element)
        @current = xpath
      elsif xpath.is_a?(String)
        @current = @document.elements[xpath]
      else
        raise "xpath is neither a String nor a REXML::Element"
      end
    end

    # returns the current xml element
    # @return [REXML::Element] the xml element after which the following elements will be added
    def get_current()
      return @current
    end

    # returns the plain text without any xml tags of the specified element and all its children
    # @param el [REXML::Element] The element from which to fetch the text children. Defaults to @current
    # @param recursive [Boolean] whether or not to recurse into the children of the given "el"
    # @return [String] text contents of xml node
    def get_element_text(el = @current, recursive = true)
      out = ""
      el.to_a.each { |child|
        if child.is_a?(REXML::Text)
          out << child.value()
        else
          if recursive
            out << get_element_text(child, true)
          end
        end
      }
      return out
    end

    # @param elem [REXML::Element]
    # @return [String]
    def element_to_string(elem)
      f = REXML::Formatters::Transitive.new(0) # use Transitive to preserve source formatting (e.g. <pre> tags)
      out = ""
      f.write(elem, out)
      return out
    end

    # @see #code
    # Instead of adding content to the report, this method returns the produced html code as a string.
    # This can be used to insert code into #custom_table (with the option data_is_xhtml: true)
    # @return [String] the code including <pre> tags as a string
    def get_code_html(attrs={}, &block)
      temp = REXML::Element.new("pre")
      temp.add_attributes(attrs)
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      temp.add_text(text)
      element_to_string(temp)
    end

    # Appends a <pre> node after the @current node
    # @param attrs [Hash] attributes for the <pre> element. The following classes can be passed as attributes and are predefined with a different
    #                     background for your convenience !{"class" => "code0"} (light-blue), !{"class" => "code1"} (red-brown),
    #                     !{"class" => "code2"} (light-green), !{"class" => "code3"} (light-yellow). You may also specify your own background
    #                     as follows: !{"style" => "background: #FF00FF;"}.
    # @yieldreturn [String] the text to be added to the <pre> element
    # @return [REXML::Element] the Element which was just added
    def code(attrs={}, &block)
      temp = REXML::Element.new("pre")
      temp.add_attributes(attrs)
      @div_middle.insert_after(@current, temp)
      @current = temp
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      @current.add_text(text)
      document_changed()
      return @current
    end

    # Appends a <script> node after the @current node
    # @param attrs [Hash] attributes for the <script> element. The following attribute is added by default:
    #                     type="text/javascript"
    # @yieldreturn [String] the actual javascript code to be added to the <script> element
    # @return [REXML::Element] the Element which was just added
    def javascript(attrs={}, &block)
      default_attrs = {"type" => "text/javascript"}
      attrs = default_attrs.merge(attrs)
      temp = REXML::Element.new("script")
      temp.add_attributes(attrs)
      @div_middle.insert_after(@current, temp)
      @current = temp
      raise "Block argument is mandatory" unless block_given?
      script_content = encoding_fixer(block.call())
      cdata(script_content, @current)
      document_changed()
      return @current
    end

    # @see #content
    # Instead of adding content to the report, this method returns the produced html code as a string.
    # This can be used to insert code into #custom_table (with the option data_is_xhtml: true)
    # @return [String] the code including <pre> tags as a string
    def get_content_html(attrs={}, &block)
      temp = REXML::Element.new("p")
      temp.add_attributes(attrs)
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      temp.add_text(text)
      element_to_string(temp)
    end

    # Appends a <p> node after the @current node
    # @param attrs [Hash] attributes for the <p> element
    # @yieldreturn [String] the text to be added to the <p> element
    # @return [REXML::Element] the Element which was just added
    def content(attrs={}, &block)
      temp = REXML::Element.new("p")
      temp.add_attributes(attrs)
      @div_middle.insert_after(@current, temp)
      @current = temp
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      @current.add_text(text)
      document_changed()
      return @current
    end

    # insert arbitrary xml code after the @current element in the content pane (div middle)
    # @param text [String] valid xhtml code which is included into the document
    # @return [REXML::Element] the Element which was just added
    def html(text)
      # we need to create a new document with a pseudo root becaus having multiple nodes at top
      # level is not valid xml
      doc = REXML::Document.new("<root>"+text.to_s+"</root>")
      # then we move all children of root to the actual div middle element and insert after current
      for i in doc.root.to_a do
        @div_middle.insert_after(@current, i)
        @current = i
      end
      document_changed()
      return @current
    end

    # @see #link
    # Instead of adding content to the report, this method returns the produced html code as a string.
    # This can be used to insert code into #custom_table (with the option data_is_xhtml: true)
    # @return [String] the code including <a> tags as a string
    def get_link_html(href, attrs={}, &block)
      temp = REXML::Element.new("a")
      attrs.merge!({"href" => href})
      temp.add_attributes(attrs)
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      temp.add_text(text)
      element_to_string(temp)
    end

    # Appends  a <a href = > node after the @current nodes
    # @param href [String] this is the
    # @param attrs [Hash] attributes for the <a> element
    # @yieldreturn [String] the text to be added to the <a> element
    # @return [REXML::Element] the Element which was just added
    def link(href, attrs={}, &block)
      temp = REXML::Element.new("a")
      attrs.merge!({"href" => href})
      temp.add_attributes(attrs)
      @div_middle.insert_after(@current, temp)
      @current = temp
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      @current.add_text(text)
      document_changed()
      return @current
    end

    # @see #image
    # Instead of adding content to the report, this method returns the produced html code as a string.
    # This can be used to insert code into #custom_table (with the option data_is_xhtml: true)
    # @return [String] the code including <pre> tags as a string
    def get_image_html(path, attributes = {})
      # read image as binary and do a base64 encoding
      binary_data = Base64.strict_encode64(IO.binread(path))
      type = File.extname(path).gsub('.', '')
      # create the element
      temp = REXML::Element.new("img")
      # add the picture
      temp.add_attribute("src","data:image/#{type};base64,#{binary_data}")
      temp.add_attributes(attributes)
      element_to_string(temp)
    end

    # @param path [String] absolute or relative path to the image that should be inserted into the report
    # @param attributes [Hash] attributes for the <img> element, any valid html attributes can be specified
    #   you may specify attributes such "alt", "height", "width"
    # @option attrs [String] "class" by default every heading is added to the left table of contents (toc)
    def image(path, attributes = {})
      # read image as binary and do a base64 encoding
      binary_data = Base64.strict_encode64(IO.binread(path))
      type = File.extname(path).gsub('.', '')
      # create the element
      temp = REXML::Element.new("img")
      # add the picture
      temp.add_attribute("src","data:image/#{type};base64,#{binary_data}")
      temp.add_attributes(attributes)

      @div_middle.insert_after(@current, temp)
      @current = temp
      document_changed()
      return @current
    end

    # Scans all REXML::Text children of an REXML::Element for any occurrences of regex.
    # The text will be matched as one, not line by line as you might think.
    # If you want to write a regexp matching multiple lines keep in mind that the dot "." by default doesn't
    # match newline characters. Consider using the "m" option (e.g. /regex/m ) which makes dot match newlines
    # or match newlines explicitly.
    # highlight_captures then puts a <span> </span> tag around all captures of the regex
    # NOTE: nested captures are not supported and don't make sense in this context!!
    # @param regex [Regexp] a regular expression that will be matched
    # @param color [String] either one of "y", "r", "g", "b" (yellow, red, green, blue) or a valid html color code (e.g. "#80BFFF")
    # @param el [REXML::Element] the Element (scope) which will be searched for pattern matches, by default the last inserted element will be scanned
    # @return [Fixnum] the number of highlighted captures
    def highlight_captures(regex, color="y", el = @current)
      # get all children of the current node
      arr = el.to_a()
      num_matches = 0
      # first we have to detach all children from parent, otherwise we can cause ordering issues
      arr.each {|i| i.remove() }
      # depth first recursion into grand-children
      for i in arr do
        if i.is_a?(REXML::Text)
          # in general a text looks as follows:
          # .*(matchstring|.*)*

          # We get an array of [[start,length], [start,length], ...] for all our regex SUB-matches
          positions = i.value().enum_for(:scan, regex).flat_map {
            # Regexp.last_match is a MatchData object, the index 0 is the entire match, 1 to n are captures
            array = Array.new
            for k in 1..Regexp.last_match.length - 1 do
              array.push([Regexp.last_match.begin(k),
                Regexp.last_match.end(k)-Regexp.last_match.begin(k)])
            end
            # return the array for the flat_map
            array
          }
          num_matches += positions.length
          if ["y","r","g","b"].include?(color)
            attr = {"class" => color}
          elsif color.match(/^#[A-Fa-f0-9]{6}$/)
            attr = {"style" => "background: #{color};"}
          else
            raise "invalid color: #{color}"
          end
          replace_text_with_elements(el, i, "span", attr, positions)
        else
          # for non-text nodes we recurse into it and finally reattach to our parent to preserve ordering
          num_matches += highlight_captures(regex, color, i)
          el.add(i)
        end # if  i.is_a?(REXML::Text)
      end # for i in arr do
      document_changed()
      return num_matches
    end

    # Scans all REXML::Text children of an REXML::Element for any occurrences of regex.
    # The text will be matched as one, not line by line as you might think.
    # If you want to write a regexp matching multiple lines keep in mind that the dot "." by default doesn't
    # match newline characters. Consider using the "m" option (e.g. /regex/m ) which makes dot match newlines
    # or match newlines explicitly.
    # highlight then puts a <span> </span> tag around all matches of regex
    # @param regex [Regexp] a regular expression that will be matched
    # @param color [String] either one of "y", "r", "g", "b" (yellow, red, green, blue) or a valid html color code (e.g. "#80BFFF")
    # @param el [REXML::Element] the Element (scope) which will be searched for pattern matches
    # @return [Fixnum] the number of highlighted captures
    def highlight(regex, color="y", el = @current)
      # get all children of the current node
      arr = el.to_a()
      num_matches = 0
      #puts arr.inspect
      # first we have to detach all children from parent, otherwise we can cause ordering issues
      arr.each {|i| i.remove() }
      # depth first recursion into grand-children
      for i in arr do
        #puts i.class.to_s()
        if i.is_a?(REXML::Text)
          # in general a text looks as follows:
          # .*(matchstring|.*)*

          # We get an array of [[start,length], [start,length], ...] for all our regex matches
          positions = i.value().enum_for(:scan, regex).map {
            [Regexp.last_match.begin(0),
              Regexp.last_match.end(0)-Regexp.last_match.begin(0)]
          }
          num_matches += positions.length
          if ["y","r","g","b"].include?(color)
            attr = {"class" => color}
          elsif color.match(/^#[A-Fa-f0-9]{6}$/)
            attr = {"style" => "background: #{color};"}
          else
            raise "invalid color: #{color}"
          end
          replace_text_with_elements(el, i, "span", attr, positions)
        else
          # for non-text nodes we recurse into it and finally reattach to our parent to preserve ordering
          # puts "recurse"
          num_matches += highlight(regex, color, i)
          el.add(i)
        end # if  i.is_a?(REXML::Text)
      end # for i in arr do
      document_changed()
      return num_matches
    end

    # creates a html table from two dimensional array of the form Array [row] [col]
    # @param table_data [Array<Array>] of the form Array [row] [col] containing all data, the '.to_s' method will be called on each element,
    # @param headers [Number] either of 0, 1, 2, 3. Where 0 is no headers (<th>) at all, 1 is only the first row,
    #   2 is only the first column and 3 is both, first row and first column as <th> elements. Every other number
    #   is equivalent to the bitwise AND of the two least significant bits with 1, 2 or 3
    # @return [REXML::Element] the Element which was just added
    def table(table_data, headers=0, table_attrs={}, tr_attrs={}, th_attrs={}, td_attrs={})
      opts = {
        headers: headers,
        data_is_xhtml: false,
        table_attrs: table_attrs,
        th_attrs: th_attrs,
        tr_attrs: tr_attrs,
        td_attrs: td_attrs,
      }
      custom_table(table_data, opts)
    end

    # creates a html table from two dimensional array of the form Array [row] [col]
    # @param table_data [Array<Array>] of the form Array [row] [col] containing all data, the '.to_s' method will be called on each element,
    # @option opts [Number] :headers either of 0, 1, 2, 3. Where 0 is no headers (<th>) at all, 1 is only the first row,
    #                       2 is only the first column and 3 is both, first row and first column as <th> elements. Every other number
    #                       is equivalent to the bitwise AND of the two least significant bits with 1, 2 or 3
    # @option opts [Boolean] :data_is_xhtml defaults to false, if true table_data is inserted as xhtml without any sanitation or escaping.
    #                                       This way a table can be used for custom layouts.
    # @option opts [Hash] :table_attrs  html attributes for the <table> tag
    # @option opts [Hash] :th_attrs     html attributes for the <th> tag
    # @option opts [Hash] :tr_attrs     html attributes for the <tr> tag
    # @option opts [Hash] :td_attrs     html attributes for the <td> tag
    # @option opts [Array<Hash>] :special Array of hashes for custom attributes on specific cells (<td> only) of the table
    # @example Example of the :special attributes
    #   opts[:special] = [
    #     {
    #       col_title: 'rx_DroppedFrameCount', # string or regexp or nil  # if neither title nor index are present, the condition is evaluated for all <td> cells
    #       col_index: 5..7,  # Fixnum, Range or nil     # index has precedence over title
    #       row_title: 'D_0_BE_iMix',  # string or regexp or nil
    #       row_index: 6,  # Fixnum, Range or nil
    #       condition: Proc.new { |e| Integer(e) != 0 },   # a proc
    #       attributes: {"style" => "background-color: #DB7093;"},
    #     },
    #   ]
    # @return [REXML::Element] the Element which was just added
    def custom_table(table_data, opts = {})
      defaults = {
        headers: 0,
        data_is_xhtml: false,
        table_attrs: {},
        th_attrs: {},
        tr_attrs: {},
        td_attrs: {},
        special: [],
      }
      o = defaults.merge(opts)

      temp = REXML::Element.new("table")
      temp.add_attributes(o[:table_attrs])
      row_titles = table_data.collect{|row| row[0].to_s}
      col_titles = table_data[0].collect{|title| title.to_s}

      for i in 0..table_data.length-1 do # row
        row = temp.add_element("tr", o[:tr_attrs])
        for j in 0..table_data[i].length-1 do # column
          if (i == 0 && (0x1 & o[:headers])==0x1)
            col = row.add_element("th", o[:th_attrs])
          elsif (j == 0 && (0x2 & o[:headers])==0x2)
            col = row.add_element("th", o[:th_attrs])
          elsif ((i == 0 || j ==0) && (0x3 & o[:headers])==0x3)
            col = row.add_element("th", o[:th_attrs])
          else
            # we need to deepcopy the attributes
            _td_attrs = Marshal.load(Marshal.dump(o[:td_attrs]))

            # check all special criteria
            o[:special].each do |h|
              # check if the current cell is a candidate for special
              if !h[:col_index].nil?
                if h[:col_index].is_a?(Range)
                  next if (!h[:col_index].include?(j)) # skip if not in range
                elsif h[:col_index].is_a?(Integer)
                  next if (h[:col_index] != j)         # skip if not at index
                end
              elsif !h[:col_title].nil?
                next if !col_titles[j].match(h[:col_title])
              end
              # check if the current cell is a candidate for special
              if !h[:row_index].nil?
                if h[:row_index].is_a?(Range)
                  next if (!h[:row_index].include?(i)) # skip if not in range
                elsif h[:row_index].is_a?(Integer)
                  next if (h[:row_index] != i)         # skip if not at index
                end
              elsif !h[:row_title].nil?
                next if !row_titles[i].match(h[:row_title])
              end

              # here we are a candidate for special, so we check if we meet the condition
              # puts h[:attributes].inspect
              # puts "cell value row #{i} col #{j}: #{table_data[i][j]}"
              # puts h[:condition].call(table_data[i][j]).inspect
              if h[:condition].call(table_data[i][j])
                h[:attributes].each { |attr, val|
                  # debug, verify deepcopy
                  # puts "objects are equal:  #{_td_attrs[attr].equal?(o[:td_attrs][attr])}"
                  if !_td_attrs[attr].nil?
                    # assume the existing attribute is a string (other types don't make much sense for html)
                    _td_attrs[attr] << val
                  else
                    # create the attribute if it is not already there
                    _td_attrs[attr] = val
                  end
                }
              end
            end

            col = row.add_element("td", _td_attrs)
          end
          if o[:data_is_xhtml]
            # we need to create a new document with a pseudo root because having multiple nodes at top
            # level is not valid xml
            doc = REXML::Document.new("<root>" + table_data[i][j].to_s + "</root>")
            # then we move all children of root to the actual div middle element and insert after current
            for elem in doc.root.to_a do
              if elem.is_a?(REXML::Text)
                # due to reasons unclear to me, text needs special treatment
                col.add_text(elem)
              else
                col.add_element(elem) # add the td element
              end
            end
          else
            col.add_text(table_data[i][j].to_s)
          end
        end # for j in 0..table_data[i].length-1 do # column
      end # for i in 0..table_data.length-1 do # row

      @div_middle.insert_after(@current, temp)
      @current = temp
      document_changed()
      return @current
    end


    # Appends a new heading element to body, and sets current to this new heading
    # @param tag_type [String] specifiy "h1", "h2", "h3" for the heading, defaults to "h1"
    # @param attrs [Hash] attributes for the <h#> element, any valid html attributes can be specified
    # @option attrs [String] "class" by default every heading is added to the left table of contents (toc)
    #   use the class "onlyrtoc" or "bothtoc" to add a heading only to the right toc or to both tocs respectively
    # @yieldreturn [String] the text to be added to the <h#> element
    # @return [REXML::Element] the Element which was just added
    def heading(tag_type="h1", attrs={}, &block)
      temp = REXML::Element.new(tag_type)
      temp.add_attributes(attrs)

      @div_middle.insert_after(@current, temp)
      @current = temp
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      @current.text = text
      document_changed()
      return @current
    end

    # Inserts a new heading element at the very beginning of the middle div section, and points @current to this heading
    # @param tag_type [String] specifiy "h1", "h2", "h3" for the heading, defaults to "h1"
    # @param attrs [Hash] attributes for the <h#> element, any valid html attributes can be specified
    # @option attrs [String] "class" by default every heading is added to the left table of contents (toc)
    #   use the class "onlyrtoc" or "bothtoc" to add a heading only to the right toc or to both tocs respectively
    # @yieldreturn [String] the text to be added to the <h#> element
    # @return [REXML::Element] the Element which was just added
    def heading_top(tag_type="h1", attrs={}, &block)
      temp = REXML::Element.new(tag_type)
      temp.add_attributes(attrs)

      # check if there are any child elements
      if @div_middle.has_elements?()
        # insert before the first child of div middle
        @div_middle.insert_before("//div[@id='middle']/*[1]", temp)
      else
        # middle is empty, just insert the heading
        @div_middle.insert_after(@current, temp)
      end

      @current = temp
      raise "Block argument is mandatory" unless block_given?
      text = encoding_fixer(block.call())
      @current.text = text
      document_changed()
      return @current
    end

    # Helper Method for the highlight methods. it will introduce specific xhtml tags around parts of a text child of an xml element.
    # @example
    #   we have the following xml part
    #   <test>
    #     some arbitrary
    #     text child content
    #   </test>
    #   now we call replace_text_with_elements to place <span> around the word "arbitrary"
    #   =>
    #   <test>
    #     some <span>arbitrary</span>
    #     text child content
    #   </test>
    # @param parent [REXML::Element] the parent to which "element" should be attached after parsing, e.g. <test>
    # @param element [REXML::Element] the Text element, into which tags will be added at the specified indices of @index_length_array, e.g. the REXML::Text children of <test> in the example
    # @param tagname [String] the tag that will be introduced as <tagname> at the indices specified
    # @param attribs [Hash] Attributes that will be added to the inserted tag e.g. <tagname attrib="test">
    # @param index_length_array [Array] Array of the form [[index, lenght], [index, lenght], ...] that specifies
    #                                   the start position and length of the substring around which the tags will be introduced
    def replace_text_with_elements(parent, element, tagname, attribs, index_length_array)
      last_end = 0
      index = 0
      #puts index_length_array.inspect
      #puts element.inspect
      for j in index_length_array do
        # reattach normal (unmatched) text
        if j[0] > last_end
          # text = REXML::Text.new(element.value()[ last_end, j[0] - last_end ])
          # parent.add_text(text)
          # add text without creating a textnode, textnode screws up formatting (e.g. all whitespace are condensed into one)
          parent.add_text( element.value()[ last_end, j[0] - last_end ] )
        end
        #create the tag node with attributes and add the text to it
        tag = parent.add_element(REXML::Element.new(tagname), attribs)
        tag.add_text(element.value()[ j[0], j[1] ])
        last_end = j[0]+j[1]

        # in the last round check for any remaining text
        if index == index_length_array.length - 1
          if last_end < element.value().length
            # text = REXML::Text.new(element.value()[ last_end, element.value().length - last_end ])
            # parent.add(text)
            # add text without creating a textnode, textnode screws up formatting (e.g. all whitespace are condensed into one)
            parent.add_text( element.value()[ last_end, element.value().length - last_end ] )
          end
        end
        index  += 1
      end # for j in positions do

      # don't forget to reattach the textnode if there are no regex matches at all
      if index == 0
        parent.add(element)
      end

    end # replace_text_with_elements

  end # Generator
end # XhtmlReportGenerator
