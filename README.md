xhtml_report_generator
======================

This project was written to provide an easy way to create valid xhtml or html documents.
My main usecases is the automatic creation of (test-)reports that are human readable and include a table of contents.
xhtml_report_generator can be used very similar like a ruby Logger, but there are some caveats.
It is not a Logger replacement, since the complete document is always kept in memory and
only written to disk on demand. Hence in case of crashes the data might be lost if it wasn't written before.

All logic (js and css) is inlined which makes it very easy to send the report to someone else by mail and view it offline.
Also pdf export is easy by just printing the report. By default there is a special css with media print making the layout suitable for printing.

Ruby version
-----
This gem was mainly tested with ruby version 2.2.3. Except of the test_encoding_issues unit tests, all other tests are 
also passing with 1.9.3.


Getting started
-------------
Create a basic report with some content, highlighted text and the default layout which includes the table of contents in
a split area on the left, and a list of quicklinks in a split area on the right.

```ruby
require 'xhtml_report_generator'

gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Title")
gen1.heading("h1", {"class" => "bothtoc"}) {"titel"}
gen1.content() {"Hello World"}
# browser will parse this as html (based on file extension)
gen1.write("myreport.html")
# browser will parse this as xhtml (based on file extension)
gen1.write("myreport.xhtml")
```

[Code](../master/examples/basic_report.rb)

[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/examples/basic_report.html)


More examples can be found in the [examples](../master/examples) or
[test](../master/test) folders


By default "custom.rb" is loaded through instance eval, see 
[XhtmlReportGenerator/Custom](http://www.rubydoc.info/gems/xhtml_report_generator/Custom) and 
[XhtmlReportGenerator/Generator](http://www.rubydoc.info/gems/xhtml_report_generator/XhtmlReportGenerator/Generator)
for the documentation of available methods.

Advanced example1: custom tables including pictures or links
----------------------------------
[Code] (../master/test/test.rb#L166-L233)
[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/examples/CustomTableReference.xhtml)


Advanced example2: including some graphs to your reports
----------------------------------
Due to the xml nature it is also easy to insert SVG graphs / pictures. Check out the svg-graph gem

```ruby
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
      :height             => 300,
      :width              => 500,
      :show_graph_title   => true,
      :graph_title        => 'Graph Title',
      :show_x_title       => true,
      :x_title            => 'Month',
      :show_y_title       => true,
      #:y_title_text_direction => :bt,
      :y_title            => 'cash',
      :fields             => x_axis})

graph.add_data({:data => data_sales_02, :title => 'Sales2002'})
graph.add_data({:data => data_sales_03, :title => 'Sales2003'})

# add the svg to the report
gen1.html(graph.burn_svg_only())
gen1.write("graph.xhtml")

```

[Code](../master/examples/graph.rb)

[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/examples/graph.xhtml)


Customizing the Report with CSS
-------------------------------
The styling of the report is done through css. This allowes you to customize most of the formatting as to your liking.
The split.js relevant section should only be changed if you know what you're doing, otherwise the layout might break.

As a starting point begin with the [default css used by the report](../master/lib/xhtml_report_generator/style_template.css)
```ruby
require 'xhtml_report_generator'

opts = {
  :css => 'path/to/my_css.css'
}

gen1 = XhtmlReportGenerator::Generator.new(opts)
gen1.create_layout("Page Title")

```

[Code](../master/examples/custom_css.rb)

[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/examples/custom_css.html)

The project is built in a way that lets you supply your own methods for everything. By default the methods , js and css files provided
with the gem are used, but you can override those by specifying your own. The primary usecase is to override the default css 
to customize the look and feel of the generated html files. But if you want you can event write your complete own generator.

As a start you can copy the [custom.rb](../master/lib/xhtml_report_generator/custom.rb) file and rename the functions if you don't like the 
default naming.


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

