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
  
  def content(text)
  end
  
  def contentAfter(locaiton, text)
  end
  
  def contentBefore(locaiton, text)
  end
  
  def highlight(start_regex, end_regex, color="y")
  
  end
  
  
  def highlight(regex, color="y", el = @current)
    # get all children of the current node
    arr = el.to_a()
    
    # depth first recursion into grand-children
    for i in arr do 
    if i.class.to_s()  == "REXML::Text"  
      
      # the following possibilities exist:
      # matchstring
      # text matchstring
      # matchstring text
      # text matchstring text
      # matchstring text matchstring
      # 
      
      match_index = 0
      while match_index != -1 do
        match_index = i.value().index(regex,match_index)
        # remove all chars up to occurence of regex
        text = i.value().substr()
      end
      
      matches = i.value().scan(regex)
      text_arr = i.value().split(regex)
      # detach from parent
      i.parent = nil 
      # reattach the splitted elements
      for j in matches.size do
        span = REXML::Element.new("span")
        # add the color if it is not default
        if color != "y"
          span.add_attribute("class",color)
          end
        span.add_text(matches[j])
        
        text_el = REXML::Text.new(text_arr[j])
        el.add()
      end
      
      
      
    else
      highlight(regex, color, i)
    end  
    
    end 
    
    
#    text = @current.text
#    matchdata = text.scan(regex)
#    arr = text.split(regex)
#    @current.te
#    for i in 0..(matchdata.lenght-1) do
#      
#    end
    
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