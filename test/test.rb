require_relative '../lib/xhtml_report_generator'

gen1 = XhtmlReportGenerator::Generator.new
#
gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "test/custom2.rb")
gen2.H1

gen1.createLayout
gen1.setTitle("Manu's Testreport")

for i in 1..20 do
  gen1.heading("h1", "titel #{"Manuel".split("").shuffle.join}", :btoc)
  gen1.heading("h2", "subtitel", :ltoc)
  gen1.heading("h3", "section")
  gen1.heading("h4", "subsection")
  gen1.content("content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>",{"class"=>"bold"})
  
  gen1.html("html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>",{"class"=>"italic"})

  # test for nested highlighting
  gen1.code("some sp fancy cisco < & > an code\nwith newline!\nand sp another second fancy blub an code")
  
  gen1.highlight(/sp.*an/)
  gen1.highlight(/second.*blub/, "g")
  gen1.highlight(/fancy/, "b")
  
  gen1.content("this is really good lookin'")
  
  
end
#puts XhtmlReportGenerator.constants()

#File.open("test1.xhtml", 'w') {|f| f.write(gen1.to_s)}

gen1.writeToFile("test1.xhtml")