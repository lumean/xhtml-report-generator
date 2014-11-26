require_relative '../xhtml_report_generator'


gen1 = XhtmlReportGenerator::Generator.new
#
gen2 = XhtmlReportGenerator::Generator.new(:custom_rb => "lib/xhtml_report_generator/custom2.rb")
gen2.H1

gen1.createLayout
gen1.setTitle("Manu's Testreport")

for i in 1..20 do
  gen1.heading("h1", "titel", :btoc)
  gen1.heading("h2", "subtitel", :ltoc)
  gen1.heading("h3", "section")
  gen1.code("some fancy cisco code\nwith newline!\nand another fancy code")
  
  gen1.highlight(1,2)
  #recurse_constants(XhtmlReportGenerator)
end
#puts XhtmlReportGenerator.constants()

File.open("test1.xhtml", 'w'){|f| f.write(gen1.to_s)}