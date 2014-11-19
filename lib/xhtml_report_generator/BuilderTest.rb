require 'builder'

builder = Builder::XmlMarkup.new(:indent => 2)

builder.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8", :standalone => "no"
builder.declare! :DOCTYPE, :html, :PUBLIC, "-//W3C//DTD XHTML 1.0 Strict//EN", "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"

builder.html(:xmlns => "http://www.w3.org/1999/xhtml") { |p| 
  p.head { |q| q.title("test xhtml")}
  p.body(:class => "test&escape") { |q| 
    q.p("Manu\nexample\with\newline")
    #"some text"
    q.text! "some other text"
    #q.text! << "some unescaped < unmodified > text"
  }
  p.comment!("this is a testcomment")
}
  

builder.html{|a| a.body {|a| a.p("test")}}

puts builder.target!