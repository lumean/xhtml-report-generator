require 'xhtml_report_generator'
require 'SVG/Graph/Line'
require 'json'

gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Graph example")

gen1.heading("h1")  {"Graph generated with c3.js"}

gen1.html("<div id=\"this_is_my_awesom_graph\" style=\"width:600px;height:400px;\"></div>")
# checkout c3.js documentation
# http://c3js.org/examples.html
graph_data = {
  bindto: '#this_is_my_awesom_graph',
  data: {
    columns: [
      ['data1', 30, 200, 100, 400, 150, 250],
      ['data2', 300, 20, 10, 40, 15, 25]
    ],
    axes: {
      data1: 'y',
      data2: 'y2',
    }
  },
  axis: {
    x: {
      label: 'X Label'
    },
    y: {
      label: {
        text: 'Y Axis Label',
        position: 'outer-middle'
      }
    },
    y2: {
      show: true,
      label: {
        text: 'Y2 Axis Label',
        position: 'outer-middle'
      }
    }
  },
  tooltip: {
#   enabled: false
  },
  zoom: {
    enabled: true
  },
  subchart: {
    show: true
  }
}
gen1.javascript() {
  "var chart = c3.generate(#{JSON(graph_data)});"
}

gen1.heading("h1") {"Graph generated with svg-graph gem"}

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
gen1.write(File.expand_path("graph.xhtml", __dir__))
