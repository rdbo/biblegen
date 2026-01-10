# Made by Rdbo

require_relative '../lib/bible.rb'
require 'logger'

edition = Bible::Edition.values[0]
if ARGV.length >= 1
  edition = ARGV[0]
end

if not Bible::Edition.values.include?(edition)
  puts "[!] Invalid edition: #{edition}\nAvailable editions: #{Bible::Edition.values}"
  exit 1
end

puts "[*] Generating Bible..."
cache_dir = './cache'
generator = Bible::Generator.new(cache_dir: cache_dir, log_level: Logger::DEBUG)
bible = generator.generate(edition)

out_file = "#{cache_dir}/bible.json"
puts "[*] Saving parsed Bible to '#{out_file}'..."
File.write(out_file, JSON.pretty_generate(bible))
puts "[*] Done"
