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
e1.add_element(e2,"myattr"=>"blubattrib")

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

cd = REXML::CData.new("<&   \n")

e1.add(cd)
e1.add_element(REXML::Element.new("b"),{"myBattrib" => "bAttr"})
e1.add_text "Hallo <> welt"

# OK so let's assume we don't have a direct handle to the element we want to change and call it elem3:
e1.add(REXML::Element.new("elem3"))

# now we need to somehow get hold of "elem3"
# use XPath for that.
three = doc.elements["//elem3"]
 
three.previous_sibling = REXML::Element.new("elem2.5")   
three.next_sibling =  REXML::Element.new("elem4")  

e2.insert_before("//elem3",REXML::Element.new("elem2.8"))
three.insert_after("//elem3", REXML::Element.new("elem3.5"))
  
three.add_text("Hallo von elem3")
child = REXML::Element.new("child")
three.add_element(child)
tt = three.add_text("after child")

puts three.size
puts three.to_a[1]
# puts three.texts()[0]
three.texts()[0].value = "test"
three.texts()[1].value = "test"
three.each {|e|
  puts e.class.to_s
  puts e
}

#textelems = tt.get_text()
#textelems.parent = nil
#tt.get_text.parent = "blub"
#e1.insert_before(child,REXML::Text.new("test"))
#three.add_text("test2")
#tarr = tt.texts()

#for i in tarr do
#  puts i.inspect
#  i = "blub#{i}"
# # e1.insert_after(i, REXML::Text.new("Hallo von elem5 aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"))  
#end


#output = ""
#doc.write(output, 2)
#puts output




