# The module needs to be called 'Custom'
module Custom
  #puts Module.nesting
  # css classes mapped to toc
  # creates the basic page layout and sets the current Element to
  # //body/div[@class='middle']
  def createLayout
    @body = @document.elements["//body"]

    if !@layout
      @body.add_element("div", {"class" => "head"})
      @body.add_element("div", {"class" => "lefttoc", "id" => "ltoc"})
      @body.add_element("div", {"class" => "righttoc", "id" => "rtoc"})
      @div_middle = @body.add_element("div", {"class" => "middle"})
      @layout = true
    end
    @current = @document.elements["//body/div[@class='middle']"]
  end

  def setTitle(title)
    pagetitle = @document.elements["//head/title"]
    pagetitle.text = title
    div = @document.elements["//body/div[@class='head']"]
    div.text = title
  end

  # set the current element the first element matched by the xpath expression
  def setPosition!(xpath)
    @current = @document.elements[xpath]
  end

  def code(text)
    pre = REXML::Element.new("pre")
    parent = @div_middle.insert_after(@current, pre)
    @current = pre
    @current.add_text(text)

  end

  def content(text, attrs={})
    @current = @div_middle.add_element("p", attrs)
    @current.add_text(text)
    return @current
  end

  def html(text, attrs={})
    @current = @div_middle.add_element("p", attrs)
    # we need to create a new document with a pseudo root
    doc = REXML::Document.new("<root>"+text+"</root>")
    # then we move all children of root to the actual <p> </p> element
    for i in doc.root.to_a do
      @current.add(i)
    end
    return @current
  end

  #TODO
  def contentAfter(locaiton, text)
  end

  #TODO
  def contentBefore(locaiton, text)
  end

  def highlight(regex, color="y", el = @current)
    # get all children of the current node
    arr = el.to_a()

    # depth first recursion into grand-children
    for i in arr do
      # detach from current
      i.parent = nil
      if i.class.to_s()  == "REXML::Text"
        # in general a text looks as follows:
        # .*(matchstring|.*)*
        # We get an array of [[start,length], [start,length], ...] for all our regex matches
        positions = i.value().enum_for(:scan, regex).map {
          [Regexp.last_match.begin(0),
            Regexp.last_match.end(0)-Regexp.last_match.begin(0)]
        }

        last_end = 0
        index = 0
        for j in positions do
          # reattach normal (unmatched) text
          if j[0] > last_end
            text = REXML::Text.new(i.value()[ last_end, j[0] - last_end ])
            el.add_text(text)
          end
          #create the span node with color and add the text to it
          span = el.add_element(REXML::Element.new("span"), {"class" => color})
          span.add_text(i.value()[ j[0], j[1] ])
          last_end = j[0]+j[1]
          # in the last round check for any remaining text
          if index == positions.length - 1
            if last_end < i.value().length
              text = REXML::Text.new(i.value()[ last_end, i.value().length - last_end ])
              el.add(text)
            end
          end
          index  += 1
        end # for j in positions do

        # don't forget to reattach the textnode if there are no regex matches at all
        if index == 0
          el.add(i)
        end
      else
        # for non-text nodes we recurse into it and finally reattacht to our parent to preserve ordering
        highlight(regex, color, i)
        el.add(i)
      end # if  i.class.to_s()  == "REXML::Text"
    end # for i in arr do
  end

  # creates a table from csv data
  def table (table_data)
  end

  # Appends a new heading element to body
  # @param type [String] specifiy "h1", "h2", "h3" for the heading
  # @param text [String] the heading text
  # @param toc [symbol] one of :ltoc, :rtoc, :btoc  depending on in which toc you want to display the heading
  # @return the added element
  def heading(type, text, toc=:ltoc)
    case toc
    when :rtoc
      opts = {"class" => "onlyrtoc"}
    when :btoc
      opts = {"class" => "bothtoc"}
    else
      opts = {}
    end

    @current = @div_middle.add_element(type, opts)
    @current.text = text

    return @current
  end

end

extend Custom
#class Test
#  include XhtmlReportGenerator::Custom
#
#end
#puts Test.new.header()