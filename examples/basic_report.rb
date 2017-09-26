require 'xhtml_report_generator'

gen1 = XhtmlReportGenerator::Generator.new
gen1.create_layout("Page Title")
gen1.heading("h1", {"class" => "bothtoc"}) {"titel"}
gen1.heading("h2") {"subtitel"}
gen1.heading("h3") {"section"}
gen1.content({"class"=>"bold"}) {"content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>"}
gen1.html("<p class=\"italic\">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")
# highlight just applies to the most recently inserted content
gen1.highlight(/Ha.*lt/)
gen1.link("https://rubygems.org/gems/xhtml_report_generator/") {"download the gem"}

gen1.heading("h2") {"Headings are numbered automatically"}
for i in 1..100
  # insert much content make the scrollbar appear
  gen1.html("<br />\n")
end

gen1.content({"class" => "rtoconly"}) {"this will appear in the quicklinks"}
# browser will parse this as html (based on file extension)
gen1.write("basic_report.html")
# browser will parse this as xhtml (based on file extension)
gen1.write("basic_report.xhtml")
