require 'rexml/document'

head = <<EOF 
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
EOF

# create the xml document
doc = REXML::Document.new(head, {:raw => :all})

# create some elements
e1 = REXML::Element.new "elem1"
e2 = REXML::Element.new "elem2"

# stack the elements
e1.add_element(e2,"myattr"=>"blub")

# add e1 to the document, 
doc.add(e1)

# add some additional stuff to the element e2 it will 'automagically' be changed in the document.
e2.attributes()["myotheratrrib"] = "testattrib2"

e2.add_text "Hallo welt"
# this will overwrite the entire 'text' content, child elements will stay
e2.text = "noch mehr"
e2.add_text "Hallo welt"

# no let's add also some content for the parent
e1.add REXML::Text.new("und nochmals & eine Zeile")
e1.text = "test"
#blub = REXML::Text.new("tests&&&", false, nil, false)

cd = REXML::CData.new("<&")

REXML::Text.new( "<&", false, nil, false ) #-> "<&"
blub = REXML::Text.new( "<&", true, nil, false ) #-> "&lt;&amp;"
#REXML::Text.new( "<&", false, nil, true ) #-> Parse exception
#REXML::Text.new( "<&", true, nil, true ) #-> "<&"

e1.add_text(cd)
e1.add_text "Hallo & welt"

# OK so let's assume we don't have a direct handle to the element we want to change and call it elem3:
e1.add(REXML::Element.new("elem3"))

# now we need to somehow get hold of "elem3"
# use XPath for that.
three = doc.elements["//elem3"]
 
three.previous_sibling = REXML::Element.new("elem2.5")   
three.next_sibling =  REXML::Element.new("elem4")  

three.insert_before("//elem3",REXML::Element.new("elem2.8"))
three.insert_after("//elem3", REXML::Element.new("elem3.5"))
  
three.text = "Hallo von elem3"

output = ""
doc.write(output, 2)
puts output




