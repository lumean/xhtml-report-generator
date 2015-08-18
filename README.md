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
gen1.create_layout("Title")
gen1.heading("h1", {"class" => "bothtoc"}) {"titel"}
gen1.heading("h2") {"subtitel"}
gen1.heading("h3") {"section"}
gen1.content() {"content function: Hallo welt <br /> html test <span class=\"r\" >red span test</span>", {"class"=>"bold"}}
gen1.html("<p class="italic">html function: Hallo welt <br /> html test <span class=\"r\" >red span test</span></p>")
gen1.highlight(/Ha.*lt/)

</pre>

Changes from version 1.x to 2.x
-------------------------------
To ease with migration here is a list with the changed function names, please also check the new synopsis

XhtmlReportGenerator::Generator :

<pre>
createXhtmlDoc  -> create_xhtml_document

writeToFile	    -> write(file=@file, mode='w')
</pre>

Custom :

<pre>
createLayout 	-> create_layout(title, layout=3)

setTitle		-> set_title(title)

getTitle		-> get_title

setCurrent!		-> set_current!(xpath)

getCurrent		-> get_current

highlightCaptures -> highlight_captures(regex, color="y", el = @current)

code 			-> code(attrs={}, &block)

content			-> content(attrs={}, &block)

heading			-> heading(tag_type="h1", attrs={}, &block)

headingTop		-> heading_top(tag_type="h1", attrs={}, &block)

</pre>

