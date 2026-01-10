# Made by Rdbo

module Bible
  require 'net/http'
  require 'fileutils'
  require 'json'
  require 'date'

  module Category
    OLD_TESTAMENT = "Old Testament"
    NEW_TESTAMENT = "New Testament"

    def self.values
      [OLD_TESTAMENT, NEW_TESTAMENT]
    end
  end

  module Edition
    CATHOLIC_PD2009 = "catholic" # Catholic Public Domain Version (2009)
    CATHOLIC_CHALLONER = "challoner" # Douay-Rheims

    def self.values
      [CATHOLIC_PD2009, CATHOLIC_CHALLONER]
    end
  end

  class Chapter
    attr_reader :title, :versicles

    def initialize(title, versicles)
      @title = title
      @versicles = versicles
    end

    def self.from_hash(hash)
      self.new(hash[:title], hash[:versicles])
    end

    def to_hash
      {
        title: @title,
        versicles: @versicles
      }
    end

    def to_json
      self.to_hash.to_json
    end
  end

  class Book
    attr_reader :name, :category, :chapters

    def initialize(name, category, chapters)
      @name = name
      @category = category
      @chapters = chapters
    end

    def self.from_hash(hash)
      self.new(hash[:name], hash[:category], hash[:chapters].map{ |x| Chapter.from_hash(x) })
    end

    def to_hash
      {
        name: @name,
        category: @category,
        chapters: @chapters.map(&:to_hash)
      }
    end

    def to_json
      self.to_hash.to_json
    end
  end

  class Bible
    attr_reader :edition, :books
    def initialize(edition, date, books)
      @edition = edition
      @date = date
      @books = books
    end

    def self.from_hash(hash)
      self.new(hash[:edition], hash[:date], hash[:books].map{|x| Book.from_hash(x)})
    end

    def to_hash
      {
        edition: @edition,
        date: @date,
        books: @books.map(&:to_hash)
      }
    end

    def to_json(*args, **kwargs, &block)
      self.to_hash.to_json(*args, **kwargs, &block)
    end
  end

  # TODO: Enforce strict path string
  class Generator
    def initialize(cache_dir: nil, log_level: Logger::INFO)
      @public_domain_bible_url = 'https://www.sacredbible.org'
      @cache_dir = cache_dir
      @logger = Logger.new($stderr)
      @logger.level = log_level

      @logger.debug("Cache directory: #{cache_dir}")
    end

    def generate(edition)
      if not Edition.values.include?(edition)
        raise "Unsupported Bible edition: #{edition}.\nEditions: #{Edition.values}"
      end

      @logger.info("Fetching Bible index...")
      index = fetch_bible_file("/#{edition}/index.htm")

      @logger.info("Parsing Bible index...")
      # NOTE: Ruby's HashMap preserves insertion order
      book_paths = index.
        scan(/<A.*? HREF="([ON]T-.+?)">(.+?)<\/A>/).
        map{|x| { x[1].gsub(/\&nbsp;/, " ") => "/#{edition}/#{x[0]}" }}.
        filter {|x| x.keys[0] != "in color"}. # remove duplicated book
        reduce({}, :merge)

      @logger.info("Generating books...")
      books = []
      for book, path in book_paths
        @logger.debug("Fetching '#{book}' => '#{path}'...")
        content = fetch_bible_file(path)
        filename = path.split("/")[-1]
        category = filename[0] == "O" ? Category::OLD_TESTAMENT : Category::NEW_TESTAMENT

        @logger.debug("Parsing '#{book}'...")
        scan = content.scan(/\{(\d+):(\d+)\}\s+(.*?)<BR>/)
        titles = content.scan(/\[.*?<A.*? class=chapter.*?>(.*?)<\/A>.*?\](?:\s*\(([^)]+))?/)
        chapters = scan.reduce([]) do |acc, x|
          # chapter = x[0]
          versicle = x[1].to_i
          text = x[2].gsub(/<[^>]*>/, "") # Remove HTML tags

          index = if versicle == 1 then acc.length else acc.length - 1 end
          title = titles[index][0]
          complement = titles[index][1]
          if complement != nil
              title += " (#{complement})"
          end
          acc[index] ||= { title: title, versicles: {} }
          acc[index][:versicles][versicle] = text
          acc
        end

        chapters = chapters.map { |x| Chapter.from_hash(x) }
        books.push(Book.new(book, category, chapters))
      end

      Bible.new(edition, Date.today.to_s, books)
    end

    private

    def fix_encoding!(str)
      str.
        force_encoding("Windows-1252").
        encode!("UTF-8")
    end

    def read_cache(path)
      if @cache_dir == nil
        return nil
      end

      cached_file = "#{@cache_dir}#{path}"
      if File.exist?(cached_file)
        @logger.debug("Storage cache hit for file: #{path}")
        return fix_encoding!(File.read(cached_file))
      end

      @logger.debug("No cache available for file: #{path}")
      return nil
    end

    def write_cache(path, content)
      if @cache_dir
        # Writes raw content to file (encoding not fixed)
        parent_path = path.split("/")[...-1].join("/")
        parent_path = "#{@cache_dir}#{parent_path}"
        FileUtils.mkdir_p(parent_path)
        File.write("#{@cache_dir}#{path}", content)
      end
    end

    # Path format: /some/file.htm
    def fetch_bible_file(path)
      cached_file = read_cache(path)
      return cached_file if cached_file != nil

      url = URI("#{@public_domain_bible_url}/#{path}")
      @logger.debug("Downloading '#{url}'...")
      content = Net::HTTP.get(url)
      @logger.debug("Download for '#{path}' finished")

      write_cache(path, content)
      fix_encoding!(content)
      return content
    end
  end
end
