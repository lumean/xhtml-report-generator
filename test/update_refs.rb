require 'fileutils'

file_list = [
  "CustomTable",
  "GetSet",
  "Image",
  "Overall",
  "Table"
]

file_list.each do |name|
  FileUtils.cp("#{name}.xhtml", "#{name}Ref.xhtml")
end
