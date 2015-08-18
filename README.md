xhtml-report-generator
======================

This project was written to provide an easy way to create valid xhtml documents.
Usecases are the automatic creation of reports (e.g. program logs) with automatically created table of contents.
xhtml-report-generator is not a Logger replacement, since the complete document is always kept in memory and
only written to disk on demand. Hence in case of crashes the data might be lost.


Example usage
-------------
In the following you can find a quick start on how to use xhtml-report-generator.
Basically the project is built in a way that lets you supply your own methods for everything.
By default "custom.rb" is loaded through instance eval, so you can check the corresponding documentation for available methods.

Note that there is a major syntax change for "custom.rb" between version 1.x and 2.x of the gem.
Here an example for version >= 2 of this gem is provided.

Basically starting from version 2 the syntax for each method of custom.rb is unified. It accepts an hash of html attributes as argument, and the actual contents as block argument.

def method({"attribute" => "value", "attribute" => "value"}) {contents}

in addition the method naming convention was changed from camelCase to underscore to comply more with ruby conventions.
 
<pre>
require 'xhtml-report-generator'

gen1 = XhtmlReportGenerator::Generator.new
gen1.createLayout
gen1.setTitle("Example Report")
gen1.heading("titel", "h1", :btoc)
gen1.heading("subtitel", "h2", :ltoc)
gen1.heading("section", "h3")
gen1.content("content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>", {"class"=>"bold"})
      gen1.html("<p class="italic">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")
</pre>

