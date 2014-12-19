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
      gen1.heading("h1", "titel #{"Manuel".split("").shuffle(random: rand).join}", :btoc)
      gen1.heading("h2", "subtitel", :ltoc)
      gen1.heading("h3", "section")
      gen1.heading("h4", "subsection")
      gen1.content("content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>",{"class"=>"bold"})

      gen1.html("html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>",{"class"=>"italic"})

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
    expected = File.read("test/reference.xhtml")
    assert(test1 == expected)
  end
  
  def testCustomizedModule()
    gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "test/custom2.rb")
    result = gen2.H1
    
    assert( result ==  "Custom2 hallo H1")
  end

end





