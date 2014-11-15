# The module needs to be called 'Custom'
module Custom
    #puts Module.nesting
    def header
      return <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
EOF
    end
    def H1
      puts "hallo H1"
    end

    def H2
      puts "hallo H2"
    end
end

extend Custom
#class Test
#  include XhtmlReportGenerator::Custom
#  
#end
#puts Test.new.header()