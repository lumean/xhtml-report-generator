xhtml_report_generator
======================

This project was written to provide an easy way to create valid xhtml or html documents.
Usecases are the automatic creation of reports (e.g. program logs) with automatically created table of contents.
xhtml_report_generator is not a Logger replacement, since the complete document is always kept in memory and
only written to disk on demand. Hence in case of crashes the data might be lost if you didn't write before.

Ruby version
-----
This gem was mainly tested with ruby version 2.2.3. Except of the test_encoding_issues unit tests, all other tests are 
also passing with 1.9.3. Probably there were issues in ruby itself for earlier versions.


Example usage
-------------
In the following you can find a quick start on how to use xhtml_report_generator.
Basically the project is built in a way that lets you supply your own methods for everything.
By default "custom.rb" is loaded through instance eval, so you can check the corresponding documentation for available methods.

Note that there is a major syntax change for "custom.rb" between version 1.x and 2.x of the gem.
Here an example for version >= 2 of this gem is provided.

Basically starting from version 2 the syntax for each method of custom.rb is unified. It accepts an hash of html attributes as argument, and the actual contents as block argument.

def method({"attribute" => "value", "attribute2" => "value2"}) {contents}

in addition the method naming convention was changed from camelCase to underscore to comply more with ruby conventions.

See <a href=http://www.rubydoc.info/gems/xhtml_report_generator/Custom>http://www.rubydoc.info/gems/xhtml_report_generator/Custom</> for the documentation of available methods.
 
<pre>
require 'xhtml_report_generator'

gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Title")
gen1.heading("h1", {"class" => "bothtoc"}) {"titel"}
gen1.heading("h2") {"subtitel"}
gen1.heading("h3") {"section"}
gen1.content({"class"=>"bold"}) {"content function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>"}
gen1.html("&lt;p class=\"italic\">html function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>&lt;/p>")
gen1.highlight(/Ha.*lt/)
gen1.link("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}
# browser will parse this as html (based on file extension)
gen1.write("myreport.html")
# browser will parse this as xhtml (based on file extension)
gen1.write("myreport.xhtml")
</pre>

Adding some graphs to your reports
----------------------------------
Due to the xml nature it is also easy to insert SVG graphs / pictures. Check out the svg-graph gem

<pre>
require 'xhtml_report_generator'
require 'SVG/Graph/Line'
require 'REXML/document'

gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Graph example")
gen1.heading("h1") {"my graph"}

x_axis = %w(Jan Feb Mar);
data_sales_02 = [12, 45, 21]
data_sales_03 = [15, 30, 40]

graph = SVG::Graph::Line.new({
       :height => 300,
      :width => 500,
  :show_graph_title      => true,
  :graph_title          => 'Graph Title',
  :show_x_title  => true,
  :x_title => 'Month',
  :show_y_title  => true,
  #:y_title_text_direction => :bt,
  :y_title => 'cash',
  :fields => x_axis})

graph.add_data({:data => data_sales_02, :title => 'Sales2002'})
graph.add_data({:data => data_sales_03, :title => 'Sales2003'})

# we can't add the entire xml document since multiple xml declarations are invalid
# so we add only 
doc = REXML::Document.new(graph.burn())
svg = doc.elements["//svg"]
out = ''
f = REXML::Formatters::Pretty.new(0)
f.compact = true
f.write(svg, out)

gen1.html(out)
gen1.write("graph.xhtml")

</pre>


Changes from version 2.x to 3.x
-------------------------------
The options for the initialize method "XhtmlReportGenerator::Generator.new" changed.
If you just use the default values (i.e. no options/using defaults) then the upgrade should be
seamless.

Changes from version 1.x to 2.x
-------------------------------
To ease with migration here is a list with the changed function names, please also check the new synopsis

XhtmlReportGenerator::Generator :

<pre>
createXhtmlDoc  -> create_xhtml_document

writeToFile	    -> write(file=@file, mode='w')
</pre>

Custom :

<pre>
createLayout 	-> create_layout(title, layout=3)

setTitle		-> set_title(title)

getTitle		-> get_title

setCurrent!		-> set_current!(xpath)

getCurrent		-> get_current

highlightCaptures -> highlight_captures(regex, color="y", el = @current)

code 			-> code(attrs={}, &block)

content			-> content(attrs={}, &block)

heading			-> heading(tag_type="h1", attrs={}, &block)

headingTop		-> heading\_top(tag_type="h1", attrs={}, &block)

</pre>

