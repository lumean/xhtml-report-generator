require 'test/unit'

require_relative '../lib/xhtml_report_generator'

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
  
  def test_overall()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("Manu's Testreport")
    # gen1.set_title("Manu's Testreport")

    seed = 123456789
    rand = Random.new(seed)

    for i in 1..10 do
      gen1.heading("h1", {"class" => "bothtoc"}) {"titel #{"Manuel".split("").shuffle(random: rand).join}"}
      gen1.heading("h2") {"subtitel"}
      gen1.heading("h3") {"section"}
      gen1.heading("h4") {"subsection"}
      gen1.content({"class"=>"bold"}) {"content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>"}

      gen1.html("<p class=\"italic\">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")

      # test for nested highlighting
      gen1.code() {"some sp fancy console < & > an code\nwith newline!\nand sp another second fancy coconut an code"}

      # assert the highlighting is counted correctly
      assert_equal(2, gen1.highlight(/sp.*an/))
      assert_equal(1, gen1.highlight(/second(.*)nut/, "g"))
      assert_equal(2, gen1.highlight(/fancy/, "b"))
      assert_equal(4, gen1.highlight_captures(/c(o)d(e)/,"r"))

      gen1.content() {"this is really good lookin'"}

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

    gen1.write("test/OverallReference1.xhtml")
    #File.open("test1.xhtml", 'w') {|f| f.write(gen1.to_s)}

    test1 = File.read("test/OverallReference1.xhtml")
    expected = File.read("test/OverallReference.xhtml")
    assert(test1 == expected, "Reports are not equal")
  end

  def test_customized_module()
    gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "test/custom2.rb")
    result = gen2.H1

    assert( result ==  "Custom2 hallo H1")
  end

  def test_table()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("Manu's Table")
    # gen1.set_title("Manu's Table")
    gen1.heading("h1", {"class" => "bothtoc"}) {"No Headers"}
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Row only"}
    table_data = [[1,2,3],[4,"passed",6],[7,8,9]]
    gen1.table(table_data,1)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Col only"}
    table_data = [[1,2,3],[4,5,6],[7,8,"failed"]]
    gen1.table(table_data,2)

    gen1.heading("h1", {"class" => "bothtoc"}) {"1st Row and 1st Col"}
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data,3)

    gen1.write("test/TableReference1.xhtml")
    test1 = File.read("test/TableReference1.xhtml")
    expected = File.read("test/TableReference.xhtml")
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

    gen1.write("test/GetSetRef1.xhtml")
    test1 = File.read("test/GetSetRef1.xhtml")
    expected = File.read("test/GetSetRef.xhtml")
    assert(test1 == expected, "Results not equal")
  end

  # regression heading top failed when middle-div has no children
  def test_heading_top()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.create_layout("")
    el = gen1.heading_top() {"test"}
    assert(el != nil, "heading_top element should not be nil")
  end
  
  
end

