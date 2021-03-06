xhtml_report_generator
======================

This project was written to provide an easy way to create valid xhtml or html5 documents.
The main use cases is the automatic creation of (test-)reports that are human readable and include a table of contents.
xhtml_report_generator can be used very similar like a ruby Logger, but there are some caveats.
It is not a Logger replacement, since the complete document is always kept in memory and
only written to disk on demand. Hence in case of crashes the data might be lost if it wasn't written before.
There is a "sync" option but it has a performance penalty if you need to generate a lot of content.

All logic (js and css) is inlined which makes it very easy to send the report by mail and view it offline.
Also pdf export is easy by just printing the report. By default there is a special css with media print making the layout suitable for printing.

Ruby version
-----
This gem was mainly tested with ruby versions >=2.6. Except of the test_encoding_issues unit tests, all other tests are
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
gen1.heading("h2") {"subtitel"}
gen1.heading("h3") {"section"}
gen1.content({"class"=>"bold"}) {"content function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>"}
gen1.html("&lt;p class=\"italic\">html function: Hallo welt &lt;br /> html test &lt;span class=\"r\" >red span test&lt;/span>&lt;/p>")
gen1.highlight(/Ha.&ast;lt/)
gen1.link("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}
# browser will parse this as html (based on file extension)
gen1.write("myreport.html")
# browser will parse this as xhtml (based on file extension)
gen1.write("myreport.xhtml")
```

[Code](../master/examples/basic_report.rb)

[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/examples/basic_report.html)

More examples can be found in the [examples](../master/examples) or [test](../master/test) folders

Documentation
-----
See [XhtmlReportGenerator/Generator](http://www.rubydoc.info/gems/xhtml_report_generator/XhtmlReportGenerator/Generator)
for the documentation of available methods.

Advanced example1: custom tables including pictures or links
----------------------------------
[Code] (../master/test/test.rb#L166-L233)

```ruby
require 'xhtml_report_generator'
gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Custom Table")
gen1.heading("h1") {"custom styling"}
table_data = [
  (0..9).collect{|i| i},
  (10..19).collect{|i| i},
  (20..29).collect{|i| i},
  (30..39).collect{|i| i},
]
table_opts = {
  :headers => 3,
  :data_is_xhtml => false,
  :special => [
    { # highlight all numbers from 0-13 green, only 11-13 should be green since the others are part of heading
      condition: Proc.new { |e| (0 <= e.to_i) && (e.to_i <= 13) },   # a proc
      attributes: {"style" => "background: #00FF00;"},
    },
    { # font-color the area if number contains a 3
      row_index: 2..3,
      col_index: 3..7,
      condition: Proc.new { |e| e.to_s.match(/3/) },   # a proc
      attributes: {"style" => "color: red;"},
    },
    { # red border around row 2-3 col with title 8
      row_title: /[23]/,
      col_title: "8",
      condition: Proc.new { |e| true },   # a proc
      attributes: {"style" => "border: 2px solid red;"},
    },
    { # black border around cell bottom right
      row_index: 2,
      col_index: 9,
      condition: Proc.new { |e| true },   # a proc
      attributes: {"style" => "border: 2px solid black;"},
    },
  ]
}
gen1.custom_table(table_data, table_opts)
gen1.heading("h1") {"Table Layout"}
table_opts = {
  :headers => 0,
  :data_is_xhtml => true,
}

a = gen1.get_code_html() {"  blub\nblab\n\t\tblib"}
b = gen1.get_image_html("path/to/test.png", {"width" => "55", "height"=> "20", "alt" => "some_interesting_text"})
c = gen1.get_content_html() {"   leading-whitespace removed"}
d = gen1.get_link_html("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}

table_data = [
  [a, d],
  [c, b]
]
gen1.custom_table(table_data, table_opts)

gen1.write("path/to/CustomTable.xhtml")
```
[Preview](https://cdn.rawgit.com/lumean/xhtml-report-generator/master/test/CustomTableReference.xhtml)


Advanced example2: including some graphs/charts to your reports
----------------------------------
Due to the xml nature it is also easy to insert SVG graphs / pictures. Check out the svg-graph gem,
or you can even natively include a c3.js graph

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
The styling of the report is done through css. This allows you to customize most of the formatting as to your liking.
The split.js relevant section should only be changed if you know what you're doing, otherwise the layout might break.

As a starting point begin with the [default css used by the report](../master/resource/css/style.css)
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
with the gem are used, but you can override those by specifying your own. The primary use case is to override the default css
to customize the look and feel of the generated html files. But if you want you can even write your own generator.
Have a look at [custom_reporter.rb](../master/lib/test/custom_reporter.rb).

Changes from version 3.x to 4.x
-------------------------------
If you just use the default values for initialize (i.e. no options/using defaults) then the upgrade should be seamless.

The option :custom_rb was removed and behavior for the initialize method "XhtmlReportGenerator::Generator.new" changed.
You should extend your own subclass from XhtmlReportGenerator::Generator to do any customization.
The js, css and css_print files given for initialize are now included after the default files. Previously if you'd
specify any of those files, only your files would have been included in the head section.

For a complete list of changes see [changelog.txt](../master/changelog.txt)

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
