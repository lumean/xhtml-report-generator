# The module name doesn't matter, just make sure at the end to 'extend' it
# because it will be 'eval'ed  by the initialize method of the XhtmlReportGenerator::Generator class.
module Custom
  
  # creates the basic page layout and sets the current Element to the main content area (middle div)
  # @example The middle div is matched by the following xPath
  #   //body/div[@class='middle']
  def createLayout
    @body = @document.elements["//body"]
    # only add the layout if it is not already there
    if !@layout
      @body.add_element("div", {"class" => "head"})
      div = @body.add_element("div", {"class" => "lefttoc", "id" => "ltoc"})
      div.add_text("Table of Contents")
      div.add_element("br")
      div = @body.add_element("div", {"class" => "righttoc", "id" => "rtoc"})
      div.add_text("Quick Links")
      div.add_element("br");div.add_element("br")
      @div_middle = @body.add_element("div", {"class" => "middle"})
      @layout = true
    end
    @current = @document.elements["//body/div[@class='middle']"]
  end

  # sets the title of the document in the header section as well as in the layout.
  # createLayout must be called before!
  def setTitle(title)
    if !@layout 
      raise "call createLayout first"
    end
    pagetitle = @document.elements["//head/title"]
    pagetitle.text = title
    div = @document.elements["//body/div[@class='head']"]
    div.text = title
  end

  # returns the title text of the report
  def getTitle()
    pagetitle = @document.elements["//head/title"]
    return pagetitle.text
  end

  # set the current element to the element or first element matched by the xpath expression.
  # The current element is the one which can be modified through highlighting.
  # @param xpath [REXML::Element|String] the element or a string
  def setCurrent!(xpath)
    if xpath.is_a?(REXML::Element)
      @current = xpath
    else
      @current = @document.elements[xpath]
    end
  end

  # returns the current xml element
  def getCurrent()
    return @current
  end

  # Appends a <pre> node after the @current node
  def code(text, attrs={})
    temp = REXML::Element.new("pre")
    temp.add_attributes(attrs)
    @div_middle.insert_after(@current, temp)
    @current = temp
    @current.add_text(text)
    return @current
  end

  # Appends a <p> node after the @current node
  def content(text, attrs={})
    temp = REXML::Element.new("p")
    temp.add_attributes(attrs)
    @div_middle.insert_after(@current, temp)
    @current = temp
    @current.add_text(text)
    return @current
  end

  # insert arbitrary xml code after the @current element in the content pane (div middle)
  def html(text)
    # we need to create a new document with a pseudo root
    doc = REXML::Document.new("<root>"+text+"</root>")
    # then we move all children of root to the actual div middle element and insert after current
    for i in doc.root.to_a do
      @div_middle.insert_after(@current, i)
      @current = i
    end
    return @current
  end

  # puts a <span> </span> tag around all captures of the regex
  # NOTE: nested captures are not supported and don't make sense in this context!!
  # @param regex [Regexp] a regular expression that will be matched
  # @param color [String] at this point one of "y", "r", "g", "b" (yellow, red, green, blue) is supported
  # @param el [REXML::Element] the Element (scope) which will be searched for pattern matches
  def highlightCaptures(regex, color="y", el = @current)
    # get all children of the current node
    arr = el.to_a()
    # depth first recursion into grand-children
    for i in arr do
      # detach from current
      i.parent = nil
      if i.class.to_s()  == "REXML::Text"
        # in general a text looks as follows:
        # .*(matchstring|.*)*

        # We get an array of [[start,length], [start,length], ...] for all our regex SUB-matches
        positions = i.value().enum_for(:scan, regex).flat_map {
          # Regexp.last_match is a MatchData object, the index 0 is the entire match and
          # indices 1..n are the captures (sub expressions)
          array = Array.new
          for k in 1..Regexp.last_match.length - 1 do
            array.push([Regexp.last_match.begin(k),
              Regexp.last_match.end(k)-Regexp.last_match.begin(k)])
          end
          array
        }
        replaceTextWithElements(el, i, "span", {"class" => color}, positions)
      else
        # for non-text nodes we recurse into it and finally reattach to our parent to preserve ordering
        highlight(regex, color, i)
        el.add(i)
      end # if  i.class.to_s()  == "REXML::Text"
    end # for i in arr do

  end

  # puts a <span> </span> tag around all matches of regex
  # @param regex [Regexp] a regular expression that will be matched
  # @param color [String] at this point one of "y", "r", "g", "b" (yellow, red, green, blue) is supported
  # @param el [REXML::Element] the Element (scope) which will be searched for pattern matches
  def highlight(regex, color="y", el = @current)
    # get all children of the current node
    arr = el.to_a()
    #puts arr.inspect
    # depth first recursion into grand-children
    for i in arr do
      # detach from current
      i.parent = nil
      #puts i.class.to_s()
      if i.class.to_s()  == "REXML::Text"
        # in general a text looks as follows:
        # .*(matchstring|.*)*

        # We get an array of [[start,length], [start,length], ...] for all our regex matches
        positions = i.value().enum_for(:scan, regex).map {
          [Regexp.last_match.begin(0),
            Regexp.last_match.end(0)-Regexp.last_match.begin(0)]
        }
        replaceTextWithElements(el, i, "span", {"class" => color}, positions)
      else
        # for non-text nodes we recurse into it and finally reattach to our parent to preserve ordering
        # puts "recurse"
        highlight(regex, color, i)
        el.add(i)
      end # if  i.class.to_s()  == "REXML::Text"
    end # for i in arr do
  end

  # creates a html table from two dimensional array of the form Array[row][col]
  # @param table_data [Array] containing all data, the '.to_s' method will be called on each element
  # @param headers [Number] either of 0, 1, 2, 3. Where 0 is no headers (<th>) at all, 1 is only the first row,
  #   2 is only the first column and 3 is both, first row and first column as <th> elements. Every other number
  #   is equivalent to the bitwise AND of the two least significant bits with 1, 2 or 3
  def table (table_data, headers=0, table_attrs={}, tr_attrs={}, th_attrs={}, td_attrs={})
    
    temp = REXML::Element.new("table")
    temp.add_attributes(table_attrs)

    for i in 0..table_data.length-1 do
      row = temp.add_element("tr", tr_attrs)
      for j in 0..table_data[i].length-1 do
        if (i == 0 && (0x1 & headers)==0x1)
          col = row.add_element("th", th_attrs)
        elsif (j == 0 && (0x2 & headers)==0x2)
          col = row.add_element("th", th_attrs)
        elsif ((i == 0 || j ==0) && (0x3 & headers)==0x3)
          col = row.add_element("th", th_attrs)
        else
          col = row.add_element("td", td_attrs)
        end
        col.add_text(table_data[i][j].to_s)
      end
    end

    @div_middle.insert_after(@current, temp)
    @current = temp
    return @current
  end

  # Appends a new heading element to body, and sets current to this new heading
  # @param text [String] the heading text
  # @param type [String] specifiy "h1", "h2", "h3" for the heading
  # @param toc [symbol] one of :ltoc, :rtoc, :btoc  depending on in which toc you want to display the heading
  # @return the added element
  def heading(text, type="h1", toc=:ltoc)
    case toc
    when :rtoc
      opts = {"class" => "onlyrtoc"}
    when :btoc
      opts = {"class" => "bothtoc"}
    else
      opts = {}
    end

    temp = REXML::Element.new(type)
    temp.add_attributes(opts)

    @div_middle.insert_after(@current, temp)
    @current = temp
    @current.text = text
    return @current
  end
  
# Inserts a new heading element at the very beginning of the middle div section, and points @current to this heading
# @param text [String] the heading text
# @param type [String] specifiy "h1", "h2", "h3" for the heading
# @param toc [symbol] one of :ltoc, :rtoc, :btoc  depending on in which toc you want to display the heading
# @return the added element
def headingTop(text, type="h1", toc=:ltoc)
  case toc
  when :rtoc
    opts = {"class" => "onlyrtoc"}
  when :btoc
    opts = {"class" => "bothtoc"}
  else
    opts = {}
  end

  temp = REXML::Element.new(type)
  temp.add_attributes(opts)
  # insert before the first child of div middle
  @div_middle.insert_before("//div[@class='middle']/*[1]", temp)
  @current = temp
  @current.text = text
  return @current
end

  # @param element [REXML::Element] the element in whose text tags will be added at the specified indices of @index_length_array
  # @param parent [REXML::Element] the parent to which @element should be attached after parsing
  # @param tagname [String] the tag that will be introduced as <tagname> at the indices specified
  # @param attribs [Hash] Attributes that will be added to the inserted tag e.g. <tagname attrib="test">
  # @param index_length_array [Array] Array of the form [[index, lenght], [index, lenght], ...] that specifies
  #                                   the start position and length of the substring around which the tags will be introduced
  def replaceTextWithElements(parent, element, tagname, attribs, index_length_array)
    last_end = 0
    index = 0
    #puts index_length_array.inspect
    #puts element.inspect
    for j in index_length_array do
      # reattach normal (unmatched) text
      if j[0] > last_end
        text = REXML::Text.new(element.value()[ last_end, j[0] - last_end ])
        parent.add_text(text)
      end
      #create the tag node with attributes and add the text to it
      tag = parent.add_element(REXML::Element.new(tagname), attribs)
      tag.add_text(element.value()[ j[0], j[1] ])
      last_end = j[0]+j[1]

      # in the last round check for any remaining text
      if index == index_length_array.length - 1
        if last_end < element.value().length
          text = REXML::Text.new(element.value()[ last_end, element.value().length - last_end ])
          parent.add(text)
        end
      end
      index  += 1
    end # for j in positions do

    # don't forget to reattach the textnode if there are no regex matches at all
    if index == 0
      parent.add(element)
    end

  end

  #private_instance_methods(:replaceTextWithElements)

end

extend Custom
#class Test
#  include XhtmlReportGenerator::Custom
#
#end
#puts Test.new.header()