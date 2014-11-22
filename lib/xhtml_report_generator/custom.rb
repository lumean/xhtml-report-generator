# The module needs to be called 'Custom'
module Custom
  #puts Module.nesting

  # @document is a valid REXML xhtml document
  def createLayout
    if !@layout
      body =@document.elements["//body"]
      body.add_element("div", {"class" => "head"})
      body.add_element("div", {"class" => "lefttoc", "id" => "ltoc"})
      body.add_element("div", {"class" => "righttoc", "id" => "rtoc"})
      body.add_element("div", {"class" => "middle"})
      @layout = true
    end
  end

  def H1
    div = @document.elements["//div"]
    div.add_text("Test")
  end

  def H2
    puts "hallo H2"
  end
end

extend Custom
#class Test
#  include XhtmlReportGenerator::Custom
#
#end
#puts Test.new.header()