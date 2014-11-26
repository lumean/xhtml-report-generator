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
    @current.text(text)
  end
  
  def content(text)
  end
  
  def contentAfter(locaiton, text)
  end
  
  def contentBefore(locaiton, text)
  end
  
  def highlight(start_regex, end_regex, color="y")
  
  end
  
  
  def highlight(regex, color="y")
    text = @current.text
    matchdata = text.scan(regex)
    arr = text.split(regex)
    @current.te
    for i in 0..(matchdata.lenght-1) do
      
    end
    
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