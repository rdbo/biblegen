# Made by Rdbo

require_relative '../lib/bible.rb'
require_relative '../lib/pdf.rb'
require 'logger'

cache_dir = "./cache"
puts "[*] Parsing 'bible.json'..."
bible = Bible::Bible.from_hash(JSON.parse(File.read("#{cache_dir}/bible.json"), symbolize_names: true))

out_file = "#{cache_dir}/bible.pdf"
puts "[*] Generating PDF..."
pdf = bible.to_pdf
puts "[*] Saving Bible document to '#{out_file}'..."
pdf.write(out_file)
puts "[*] Done"
