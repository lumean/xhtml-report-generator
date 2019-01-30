# encoding: utf-8
require 'test/unit'

require_relative '../lib/xhtml_report_generator'
require_relative 'custom_reporter'

# compat mixin for Ruby >1.9.1 with test-unit gem in Eclipse
module Test
  module Unit
    module UI
      SILENT = false
    end

    class AutoRunner
      def output_level=(level)
        self.runner_options[:output_level] = level
      end
    end
  end
end

class TestReportGenerator < Test::Unit::TestCase

  def setup
    @cd = File.expand_path("..", __FILE__)
  end

  def test_encoding_issues()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("report")
    gen1.heading("h1", {"class" => "bothtoc"}) {"Encoding"}
    # U+01BA	ƺ	c6 ba	LATIN SMALL LETTER EZH WITH TAIL
    teststring = "\xE2\x80hallo\x98\x99\xc6\xbaäöü"
    #puts "Encoding of teststring: #{teststring.encoding()}"

    gen1.content() {teststring}
    gen1.highlight(/hallo/)
    gen1.heading("h1") {"Special characters"}
    gen1.heading("h2") {"XML forbidden chars"}
    gen1.content() {"< > /> ;&   <http://www.cl.cam.ac.uk/~mgk25/> "}
    gen1.code() {"< > /> ;&     <http://www.cl.cam.ac.uk/~mgk25/> "}
    gen1.heading("h3") {"UTF-8 encoding stress test"}
    content = IO.binread("#{@cd}/UTF-8-test.txt")
    gen1.content() {"Encoding: #{content.encoding()}"}
    gen1.code() {content}
    gen1.write("#{@cd}/test_encoding.xhtml")
    gen1.write("#{@cd}/test_encoding.html")
    # check if LATIN SMALL LETTER EZH WITH TAIL  is in final output
    result = IO.binread("#{@cd}/test_encoding.xhtml").force_encoding('UTF-8')
    #puts "valid encoding? : #{result.valid_encoding?}"
    assert(result.match(/\u01baäöü/u), "ƺ (\\u01baäöü was not found")
  end

  def test_overall()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.write("#{@cd}/Overall.xhtml")
    # performance impact of sync for this testcase (using spinning harddrive not ssd):
    # sync = true => 9 seconds
    # sync = false => 0.3 seconds
    gen1.sync = true
    gen1.create_layout("XHTML's Testreport")

    for i in 1..10 do
      gen1.heading("h1", {"class" => "bothtoc"}) {"titel #{i+100}"}
      gen1.heading("h2") {"subtitel"}
      gen1.link("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}
      gen1.heading("h3") {"section"}
      gen1.heading("h4") {"subsection"}
      gen1.content({"class"=>"bold"}) {"content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>"}

      gen1.html("<p class=\"italic\">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")

      # test for nested highlighting
      gen1.code() {"            whitespace          some sp fancy console < & > an code\nwith newline!\nand sp another second fancy coconut an \t\t2tabs code"}

      # assert the highlighting is counted correctly
      assert_equal(2, gen1.highlight(/sp.*an/))
      assert_equal(1, gen1.highlight(/second(.*)nut/, "g"))
      assert_equal(2, gen1.highlight(/fancy/, "b"))
      assert_equal(4, gen1.highlight_captures(/c(o)d(e)/,"r"))
      # check zero match
      assert_equal(0, gen1.highlight(/this_regex_will_not_match/,"r"))
      # check captures without captures
      assert_equal(0, gen1.highlight_captures(/this_regex_will_not_match/,"r"))
      assert_equal(0, gen1.highlight_captures(/this_regex_will_(not)_match/,"r"))

      gen1.code() {"
      asdfjkl

      abc

      def

      abc

      def

      abc

      ajkdlf

      "}

      # in previous versions multiple highlights in reverse order would screw up text ordering.
      gen1.highlight(/def/, 'g')
      gen1.highlight(/abc/, 'y')
      #
      assert_match(/asdfjkl\n\n\s+abc/, gen1.get_element_text())

      gen1.content() {"this is some normal content"}

      gen1.code({"class" =>"code1"}) {
        "some other Code from another device\nwith a very long line that really should be wraped." \
        + "................................................................................................................."
      }
      gen1.code({"class" =>"code2"}) {
        "some other Code from another device\nwith a very long line that really should be wraped." \
        + "................................................................................................................."
      }
      gen1.code({"class" =>"code3"}) {
        "some other Code from another device\nwith a very long line that really should be wraped." \
        + "................................................................................................................."
      }

    end

    gen1.write("#{@cd}/Overall.htm")
    gen1.write("#{@cd}/Overall.xhtml")

    test1 = File.read("#{@cd}/Overall.xhtml")
    test2 = File.read("#{@cd}/Overall.htm")
    expected = File.read("#{@cd}/OverallRef.xhtml")
    assert(test1 == expected, "Reports are not equal")
    assert(test2 == expected, "Reports are not equal")
  end

  def test_subclassing()
    gen2 = CustomReporter.new()
    result = gen2.H1

    assert( result ==  "Custom2 hallo H1")
  end

  def test_table()
    pass_fail_js = File.expand_path("../../resource/passfail_bgcolor.js", __FILE__)
    opts = {:js => [ pass_fail_js ] }
    gen1 = XhtmlReportGenerator::Generator.new(opts)
    gen1.create_layout("Standard Table")
    # gen1.set_title("Table")
    gen1.heading("h1", {"class" => "bothtoc"}) {"No Headers"}
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Row only"}
    table_data = [[1,2,3],[4,"passed",6],[7,8,9]]
    gen1.table(table_data,1)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Col only"}
    table_data = [
      [1,2,"check"],
      [4,5,"passed"],
      [7,8,"failed"]]
    gen1.table(table_data,2)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Row and 1st Col"}
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data,3)

    gen1.write("#{@cd}/Table.xhtml")
    test1 = File.read("#{@cd}/Table.xhtml")
    expected = File.read("#{@cd}/TableRef.xhtml")
    assert(test1 == expected, "Reports are not equal")
  end

  def test_custom_table()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("Custom Table")

    gen1.heading("h1") {"1st Row and 1st Col headings"}
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
    gen1.content() {"highlight all numbers from 0-13 green, only 11-13 should be green since the others are part of heading"}
    gen1.content() {"font-color the area 23-27 : 33-37 if number contains a 3"}
    gen1.content() {"red border around row 2-3 col with title 8"}
    gen1.content() {"border around cell bottom right"}
    gen1.custom_table(table_data, table_opts)

    gen1.heading("h1") {"Table Layout"}
    table_opts = {
      :headers => 0,
      :data_is_xhtml => true,
    }

    a = gen1.get_code_html() {"  blub\nblab\n\t\tblib"}
    b = gen1.get_image_html("#{@cd}/test.png", {"width" => "55", "height"=> "20", "alt" => "some_interesting_text"})
    c = gen1.get_content_html() {"   leading-whitespace removed"}
    d = gen1.get_link_html("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}

    table_data = [
      ["plain text<br />other text<br />newline", a, d],
      ["lorem ipsum", c, b]
    ]
    gen1.custom_table(table_data, table_opts)

    gen1.heading("h1") {"Highlighter"}
    my_table = [["Stream_Name", "tx_FrameCount", "rx_FrameCount", "tx_FrameRate", "rx_FrameRate", "tx_BitRate", "rx_BitRate", "rx_AvgLatency", "rx_DroppedFrameCount", "rx_DroppedFrameRate"],
    ["D_0_BE_iMix", "1084", "1058", "23", "23", "74944", "83760", "646.211", "0", "0"],
    ["D_1_General_iMix", "767", "750", "15", "15", "42424", "50000", "660.723", "0", "1"],
    ["D_2_Prio_iMix", "2072", "2027", "39", "39", "125168", "121584", "651.951", "0", "0"],
    ["D_3_HPrio_iMix", "4377", "4288", "78", "78", "278232", "264584", "651.53", "3", "0"],
    ["D_4_Video_iMix", "6044", "5926", "104", "104", "364248", "368800", "651.178", "0", "0"],
    ["D_5_RT_218", "28182", "27534", "574", "575", "1019424", "1020608", "535.699", "0", "0"],
    ["U_0_BE_iMix", "760", "695", "23", "23", "84384", "93448", "603.051", "0", "0"],
    ["U_1_General_iMix", "556", "513", "15", "15", "51904", "50064", "616.774", "0", "2"],
    ["U_2_Prio_iMix", "1561", "1490", "39", "39", "133280", "131448", "618.291", "0", "0"],
    ["U_3_HPrio_iMix", "3279", "3135", "78", "78", "322984", "319304", "603.712", "3", "0"],
    ["U_4_Video_iMix", "4580", "4389", "104", "104", "383496", "394288", "599.501", "0", "0"],
    ["U_5_RT_218", "20103", "18474", "574", "575", "1019776", "1020608", "519.377", "0", "0"]]

   table_opts = {
            :headers => 3,
            :table_attrs => {"style"=>"text-align:right; border-collapse: collapse; font-size:14px;padding:5px 5px;"},
            :tr_attrs => {},
            :th_attrs => {"style"=>"text-align:left; border: 1px solid black; background-color:#f0f0f0;padding:5px 5px;"},
            :td_attrs => {"style"=>"border: 1px solid black;padding:5px 5px;"},
            :data_is_xhtml => false,
            :special => [
              {
                col_title: "rx_DroppedFrameCount|rx_DroppedFrameRate",
                condition: Proc.new { |e| e.to_i != 0 },
                attributes: {"style" => "background: red;"},
              },
              {
                col_title: "rx_DroppedFrameRate",
                condition: Proc.new { |e| e.to_i == 0 },
                attributes: {"style" => "background: green;"},
              },
      ]
    }

    gen1.custom_table(my_table, table_opts)

    gen1.write("#{@cd}/CustomTable.xhtml")
    test1 = File.read("#{@cd}/CustomTable.xhtml")
    expected = File.read("#{@cd}/CustomTableRef.xhtml")
    assert(test1 == expected, "Reports are not equal")
  end

  def test_get_set_current()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("")
    gen1.code() {"some example code before we put a heading"}
    gen1.heading("h1", {"class" => "bothtoc"}) {"test"}
    gen1.content() {"blabsklfja;lsjdfka;sjdf;als"}
    cur = gen1.get_current()

    gen1.heading_top() {"this is before 'test'"}
    gen1.content() {"here we are before 'test'"}
    gen1.set_current!(cur)
    gen1.content() {"here we are at the end"}

    gen1.write("#{@cd}/GetSet.xhtml")
    test1 = File.read("#{@cd}/GetSet.xhtml")
    expected = File.read("#{@cd}/GetSetRef.xhtml")
    assert(test1 == expected, "Results not equal")
  end

  def test_layout()
    for i in 0..3 do
      gen1 = XhtmlReportGenerator::Generator.new
      gen1.create_layout("layout #{i}", i)
      for j in 1..100 do
        gen1.heading("h1", "class"=>"bothtoc") {"test #{j}"}
      end
      gen1.write("#{@cd}/layout#{i}.xhtml")
      gen1.write("#{@cd}/layout#{i}.html")
    end
  end

  # regression heading top failed when middle-div has no children
  def test_heading_top()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("")
    el = gen1.heading_top() {"test"}
    assert(el != nil, "heading_top element should not be nil")
  end

  # testcase for images
  def test_image()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("titel")
    el = gen1.heading() {"PNG"}
    # insert image with explicit size and alt-text
    gen1.image("#{@cd}/test.png", {"width" => "55", "height"=> "20", "alt" => "some_interesting_text"})

    el = gen1.heading() {"JPG"}
    gen1.content() {"ending .jpg"}
    # insert image with explicit size (style notation)
    gen1.image("#{@cd}/test.jpg", {"style" => "width:33px;height:27px;"})
    gen1.content() {"ending .jpeg"}
    # insert image with automatic size (no additional attributes)
    gen1.image("#{@cd}/test.jpeg")

    gen1.write("#{@cd}/Image.xhtml")

    test1 = File.read("#{@cd}/Image.xhtml")
    expected = File.read("#{@cd}/ImageRef.xhtml")
    assert(test1 == expected, "Results not equal")
    #assert(el != nil, "heading_top element should not be nil")
  end

  def test_invalid_cdata_encoding()

    opts = {:js => [ "#{@cd}/UTF-8-test.txt" ] }
    XhtmlReportGenerator::Generator.new(opts)

  end

end
