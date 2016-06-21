require_relative '../lib/xhtml_report_generator'
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

# we can't add the entire xml document since multiple xml declarations are invalid
# so we add only the svg part
doc = REXML::Document.new(graph.burn())
svg = doc.elements["//svg"]
out = ''
f = REXML::Formatters::Pretty.new(0)
f.compact = true
f.write(svg, out)

gen1.html(out)
gen1.write("graph.xhtml")