#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'nokogiri'
require 'open-uri'

LANGUAGE_SET = ['Ruby', 'JavaScript', 'Java', 'C#', 'Visual Basic .NET',
                'Perl', 'Python', 'Groovy', 'Scala', 'Bash',
                'C++', 'C', 'Assembly language',
                'Haskell', 'PHP', 'Clojure', 'Scheme', 'OCaml', 'F#', 'Rust',
                'Makefile']

# 起動時の引数がwebなら、TIOBEのサイトからHTMLを収集して解析する
# それ以外の引数なら、その引数をファイルパスとみなしてそのHTMLファイルを解析する
ARG_REMOTE = 'web'
URL_REMOTE = 'https://www.tiobe.com/tiobe-index/'

class Language
  attr_reader :rank, :name, :rating, :shortName

  def initialize(arg)
    @rank = 0
    @name = ""
    @rating = 0.0

    if (arg.is_a?(String))
      @name = arg
    else
      @rank, @name, @rating = parse(arg)
    end

    @shortName = @name.downcase.tr(" ","")
  end

  def parse(tr)
    rank = 0
    name = ""
    rating = 0.0
    size = tr.xpath('td').size

    if (size == 3) || (size == 6)
      indexSet = (size == 6) ? [1, 4, 5] : [1, 2, 3]
      rankText, nameText, ratingText = indexSet.map { |i| getText(tr, i) }
      rank = rankText.to_i
      name = nameText
      rating = ratingText.tr('%','').to_f
    end

    return rank, name, rating
  end

  def getText(tr, index)
    tr.xpath("td[#{index}]").inner_text.lines.join("").chomp.strip
  end

  def to_s
    (@rank.nil? || @rank == 0) ? "|-|#{@name}||" : "|#{@rank}|#{@name}|#{@rating}|"
  end
end

class LanguageSet
  def initialize(is)
    doc = Nokogiri::HTML(is)
    tableTop20 = doc.xpath('//table[@class="table table-striped table-top20"]/tbody/tr')
    table21To50 = doc.xpath('//table[@class = "table table-striped"]/tbody/tr')

    langs = []
    tableTop20.each { |tr| langs << Language.new(tr) }
    table21To50.each { |tr| langs << Language.new(tr) }
    @langs = langs.reject{ |lang| lang.rank.nil? || (lang.rank == 0) }.sort_by(&:rank)
  end

  def makeTable
    usedLangs = LANGUAGE_SET.map { |name| Language.new(name) }

    rating = 0.0
    str =  "|TIOBE index 順位|Programming Language|Ratings[%]|累積[%]|\n"
    str += "|:--|:------|:------|:------|\n"

    @langs.each do |lang|
      if (usedLangs.any? { |usedLang| usedLang.shortName == lang.shortName })
        rating += lang.rating
        ratingStr = sprintf("%.3f", rating)
        str += "#{lang}#{ratingStr}|\n"
        usedLangs.reject! { |usedLang| usedLang.shortName == lang.shortName }
      end
    end

    usedLangs.each { |lang| str += "#{lang}|\n" }
    str
  end
end

class LanguageTablePrinter
  def initialize(path)
    is = (path.downcase == ARG_REMOTE.downcase) ? open(URL_REMOTE) : File.read(path)
    puts LanguageSet.new(is).makeTable
  end
end

if ARGV.size == 0
  warn "set 'web' or a local-file-path to the first arg"
  exit(1)
end

LanguageTablePrinter.new(ARGV[0])
exit(0)
