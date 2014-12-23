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
  def testOverall()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.createLayout
    gen1.setTitle("Manu's Testreport")

    seed = 123456789
    rand = Random.new(seed)

    for i in 1..10 do
      gen1.heading("titel #{"Manuel".split("").shuffle(random: rand).join}", "h1", :btoc)
      gen1.heading("subtitel", "h2", :ltoc)
      gen1.heading("section", "h3")
      gen1.heading("subsection", "h4")
      gen1.content("content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>", {"class"=>"bold"})

      gen1.html("<p class=\"italic\">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")

      # test for nested highlighting
      gen1.code("some sp fancy cisco < & > an code\nwith newline!\nand sp another second fancy coconut an code")

      gen1.highlight(/sp.*an/)
      gen1.highlight(/second(.*)nut/, "g")
      gen1.highlight(/fancy/, "b")
      gen1.highlightCaptures(/c(o)d(e)/,"r")

      gen1.content("this is really good lookin'")

    end

    gen1.writeToFile("test/test1.xhtml")
    #File.open("test1.xhtml", 'w') {|f| f.write(gen1.to_s)}

    test1 = File.read("test/test1.xhtml")
    expected = File.read("test/OverallReference.xhtml")
    assert(test1 == expected)
  end

  def testCustomizedModule()
    gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "test/custom2.rb")
    result = gen2.H1

    assert( result ==  "Custom2 hallo H1")
  end

  def testTable()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.createLayout
    gen1.setTitle("Manu's Table")
    gen1.heading("No Headers", "h1", :btoc)
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data)

    gen1.heading("1st Row only", "h1", :btoc)
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data,1)

    gen1.heading("1st Col only", "h1", :btoc)
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data,2)

    gen1.heading("1st Row and 1st Col", "h1", :btoc)
    table_data = [[1,2,3],[4,5,6],[7,8,9]]
    gen1.table(table_data,3)

    gen1.writeToFile("test/table1.xhtml")
    test1 = File.read("test/table1.xhtml")
    expected = File.read("test/TableReference.xhtml")
    assert(test1 == expected)
  end

  def testGetSetCurrent()
    gen1 = XhtmlReportGenerator::Generator.new
    gen1.createLayout
    gen1.code("some example code before we put a heading")
    gen1.heading("test", "h1", :btoc)
    gen1.content("blabsklfja;lsjdfka;sjdf;als")
    cur = gen1.getCurrent()
    
    gen1.headingTop("this is before 'test'")
    gen1.content("here we are before 'test'")
    gen1.setCurrent!(cur)
    gen1.content("here we are at the end")
    
    gen1.writeToFile("test/toptest1.xhtml")
    test1 = File.read("test/toptest1.xhtml")
    expected = File.read("test/GetSetRef.xhtml")
    assert(test1 == expected)
  end
  
end

