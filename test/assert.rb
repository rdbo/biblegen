require 'json'

bible = JSON.parse(File.read("cache/bible.json"))
edition = bible["edition"]
puts "[*] Bible edition: #{edition}"

puts "[*] Verifying Bible citations..."
# Verify some famous citations to assure the parse is good
citations = {
  "catholic" => [
    ["Matthew", "Matthew 5", "3", '“Blessed are the poor in spirit, for theirs is the kingdom of heaven.'],
    ["Psalms", "Psalm 22 (23)", "1", 'A Psalm of David. The Lord directs me, and nothing will be lacking to me.'], # NOTE: Psalm 23 is chapter 22
    ["John", "John 3", "16", "For God so loved the world that he gave his only-begotten Son, so that all who believe in him may not perish, but may have eternal life."],
    ["Genesis", "Genesis 1", "1", "In the beginning, God created heaven and earth."],
    ["Revelation", "Revelation 22", "21", "The grace of our Lord Jesus Christ be with you all. Amen."]
  ],
  "challoner" => [
    ["Matthew", "Matthew 5", "3", 'Blessed are the poor in spirit: for theirs is the kingdom of heaven.'],
    ["Psalms", "Psalms 22", "1", 'A psalm for David. The Lord ruleth me: and I shall want nothing.'],
    ["John", "John 3", "16", "For God so loved the world, as to give his only begotten Son: that whosoever believeth in him may not perish, but may have life everlasting."],
    ["Genesis", "Genesis 1", "1", "In the beginning God created heaven, and earth."],
    ["Revelation", "Revelation 22", "21", "The grace of our Lord Jesus Christ be with you all. Amen."]
  ]
}


for citation in citations[edition]
  book = citation[0]
  title = citation[1]
  versicle = citation[2]
  expected_text = citation[3]

  puts "Verifying '#{title}:#{versicle}'..."

  text = bible["books"].find{ |x| x["name"] == book }["chapters"].find { |x| x["title"] == title }["versicles"][versicle]

  raise "Incorrect citation: #{title}:#{versicle}.\nFound:    '#{text}'\nExpected: '#{expected_text}'" if text != expected_text
end

puts "[*] Done"
