# The module needs to be called 'Custom'
require_relative '../lib/xhtml_report_generator'

class CustomReporter < XhtmlReportGenerator::Generator
    #puts Module.nesting
    def header
      return <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<head>custom2</head>
EOF
    end
    def H1
      return "Custom2 hallo H1"
    end

    def H2
      puts "Custom2 hallo H2"
    end
end
