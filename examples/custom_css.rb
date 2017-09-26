require 'xhtml_report_generator'

opts = {
  :css => ['custom_css.css']
}

gen1 = XhtmlReportGenerator::Generator.new(opts)
gen1.create_layout("Changed Body BG color")
gen1.content() {"Following changes were made to the css:"}

a =<<HEREDOC
body {
	background: #2E2E2E;
}

p {
  background: #2E2E2E;
 	color: #FFFFFF;
}
HEREDOC

gen1.code() {a}

gen1.write('custom_css.html')
