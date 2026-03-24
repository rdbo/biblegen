require 'json'
require_relative '../lib/biblegen.rb'

bible = BibleGen::Bible.from_hash(JSON.load_file("cache/bible.json", symbolize_names: true))
edition = bible.edition
puts "[*] Bible edition: #{edition}"

puts "[*] Verifying Bible citations..."
# Verify some famous citations to assure the parse is good
citations = {
  "catholic" => [
    ["Matthew", 5, 3, '“Blessed are the poor in spirit, for theirs is the kingdom of heaven.'],
    ["Psalms", 22, 1, 'A Psalm of David. The Lord directs me, and nothing will be lacking to me.'], # NOTE: Psalm 23 is chapter 22
    ["John", 3, 16, "For God so loved the world that he gave his only-begotten Son, so that all who believe in him may not perish, but may have eternal life."],
    ["Genesis", 1, 1, "In the beginning, God created heaven and earth."],
    ["Revelation", 22, 21, "The grace of our Lord Jesus Christ be with you all. Amen."],
    ["Ephesians", 4, 32, "And be kind and merciful to one another, forgiving one another, just as God has forgiven you in Christ."]
  ],
  "challoner" => [
    ["Matthew", 5, 3, 'Blessed are the poor in spirit: for theirs is the kingdom of heaven.'],
    ["Psalms", 22, 1, 'A psalm for David. The Lord ruleth me: and I shall want nothing.'],
    ["John", 3, 16, "For God so loved the world, as to give his only begotten Son: that whosoever believeth in him may not perish, but may have life everlasting."],
    ["Genesis", 1, 1, "In the beginning God created heaven, and earth."],
    ["Revelation", 22, 21, "The grace of our Lord Jesus Christ be with you all. Amen."],
    ["Ephesians", 4, 32, "And be ye kind one to another: merciful, forgiving one another, even as God hath forgiven you in Christ."]
  ]
}


for citation in citations[edition]
  book = citation[0]
  chapter = citation[1]
  title = "#{book} #{chapter}"
  versicle = citation[2]
  expected_text = citation[3]

  puts "Verifying '#{title}:#{versicle}'..."

  text = bible.citation(book, chapter, versicle).versicles.values.first
  raise "Incorrect citation: #{title}:#{versicle}.\nFound:    '#{text}'\nExpected: '#{expected_text}'" if text != expected_text
end

puts "[*] Done"
