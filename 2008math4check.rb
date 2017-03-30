#!/usr/bin/ruby
# coding: utf-8
#
# 麻布中学校 2008年 入試問題 算数 問4 を解いてテストする

require 'open3'
require 'open-uri'
require 'nokogiri'

# 問4の解
SOLUTION_SET = [["9=1*2+3+4", "10=1+2+3+4", "10=1*2*3+4", "11=1+2*3+4",
                 "14=1*2+3*4", "15=1+2+3*4", "24=1*2*3*4", "25=1+2*3*4",
                 "1+2+3*4+5==2+3+4+5+6", "1*2+3+4*5==2+3*4+5+6"],
                ["9=1*2+3+4", "10=1*2*3+4", "10=1+2+3+4", "11=1+2*3+4",
                 "14=1*2+3*4", "15=1+2+3*4", "24=1*2*3*4", "25=1+2*3*4",
                 "1+2+3*4+5==2+3+4+5+6", "1*2+3+4*5==2+3*4+5+6"]]

# Gaucheは C:\bin\Gauche\bin に、
# Clojure(clojure-1.8.0.jar) は C:\bin\clojure\ に、
# clojure.math.combinatorics は C:\bin\clojure\package にあるという前提

LARGE_TEST_CASE = "1 10 2 11"
LARGE_COMMAND_SET = ["./2008math4c nomap",
                     "./2008math4c map",
                     "./2008math4rs",
                     "vsproject/cs2008math4/cs2008math4/bin/Release/cs2008math4",
                     "python3 2008math4.py fast",
                     "python3 2008math4.py slow",
                     "ruby 2008math4.rb",
                     "ruby 2008math4b.rb"]

VERY_LARGE_TEST_CASE = "1 18 2 19"
VERY_LARGE_COMMAND_SET = ["./2008math4c map",
                          "./2008math4rs"]

COMMAND_SET = [["ruby 2008math4.rb"],
               ["ruby 2008math4a.rb"],
               ["ruby 2008math4b.rb"],
               ["vsproject/cs2008math4/cs2008math4/bin/Release/cs2008math4"],
               ["vsproject/vb2008math4/vb2008math4/bin/Release/vb2008math4"],
               ["vsproject/fs2008math4/fs2008math4/bin/Release/fs2008math4"],
               ["node 2008math4.js"],
               ["javac 2008math4.java", "java -cp . Exam2008Q4"],
               ["perl 2008math4.pl"],
               ["python3 2008math4.py"],
               ["groovy 2008math4.groovy"],
               ["scala 2008math4.scala fast"],
               ["scala 2008math4.scala"],
               ["bash 2008math4.sh"],
               ["make -f 2008math4.mk"],
               ["./2008math4c"],
               ["./2008math4a"],
               ["./2008math4hs"],
               ["./2008math4rs"],
               ['java -cp "C:\\bin\\clojure\\package;C:\\bin\\clojure\\clojure-1.8.0.jar" clojure.main 2008math4.clj'],
               ["/cygdrive/c/bin/Gauche/bin/gosh.exe -I . 2008math4.scm"],
               ["ocaml 2008math4.ml"]]

# XAMPPをインストールし、HTTPサーバを8020番ポートで立ち上げ、
# htdocsにコンテンツを置いてあるという前提
URL_SET = ["http://localhost:8020/2008math4.php"];

class Solution
  def initialize(solution)
    @orignal = solution
    @solution = canonicalize(parse(solution))
  end

  def compare
    result = SOLUTION_SET.any?{ |s| @solution == s }
    message = result ? "same as expected" : "different from expected"
    [result, message]
  end

  def parse(arg)
    str = arg.chomp
    return [] if str.empty?

    [:parseScalaLog, :parseSchemeLog, :parseClojureLog, :parseHaskellLog, :parseRubyLog].each do |f|
      strSet = send(f, str)
      return strSet if strSet
    end

    str.lines.reject{ |s| s.include?("make") || !s.match(/^\s*$/).nil? }
  end

  def parseScalaLog(str)
    return nil unless str.include?("msec")

    strSet = str.lines.map do |line|
      if line.include?("msec")
        nil
      elsif line.include?("List")
        md = line.match(/List\(([^(]+)\)/)
        md.nil? ? "" : md[1]
      else
        md = line.match(/(\d+),([^(]+)\)/)
        md.nil? ? "" : (md[1] + "=" + md[2])
      end
    end.compact

    strSet
  end

  def parseSchemeLog(str)
    return nil if str.length < 3 || str[0..1] != "(("

    str.lines.map do |originalLine|
      arg = originalLine.chomp
      if (arg.size < 2 || arg[0] != "(" || arg[-1] != ")")
          ""
      else
        arg[1..-2].scan(/\(([^)]+?)\)/).flatten.map { |line| line.tr(" ","") }
      end
    end.flatten
  end

  def parseClojureLog(str)
    return nil if str.length < 3 || str[0] != "[" || str[-1] != ")"

    str.lines.map do |line|
      if (line.count("[") > 1)
        line.scan(/\s+\(([^)]+?)\)/).join("==")
      else
        md = line.match(/(\d+)\s*\(([^)]+)\)/)
        md.nil? ? "" : (md[1] + "=" + md[2])
      end
    end
  end

  def parseHaskellLog(str)
    return nil if str.length < 5 || str[0..1] != "[(" || str[-2..-1] != ")]"
    lines = str.split(/\n/).map(&:chomp)
    return if lines.size != 2

    convert = -> (str, op) { str.scan(/\(([^)]+?)\)/).flatten.map{ |s| s.tr('"','').gsub(",", op) }}
    convert[lines[0], "="] + convert[lines[1], "=="]
  end

  def parseRubyLog(str)
    return nil if str.length < 3 || str[0] != "[" || str[-1] != "]"
    str.split(/,|\n/).map(&:chomp)
  end

  def canonicalize(strSet)
    return [] if strSet.nil?
    lines = strSet.map{ |str| str.chomp.tr('" ()[]','') }
    solution1 = lines.reject { |line| line.include?("==") }.sort_by(&:to_i)
    solution2 = lines.select { |line| line.include?("==") }
    solution1 + solution2
  end
end

class LargeSet
  def initialize(testCase, commandSet)
    passed = 0
    failed = 0
    error = 0
    baseResult = []
    baseResultStr = "."

    commandSet.each do |command|
      puts "--------------------\n"
      commandLine = command + " " + testCase
      print "#{commandLine} : "

      status = 0
      originalLines = 0
      result = []
      begin
        stdoutstr, stderrstr, status = Open3.capture3(commandLine)
        originalLines, result = formatResult(stdoutstr) if status == 0
      rescue
      ensure
        if status != 0 || result.empty?
          puts "Error\n"
          error += 1
        else
          if baseResult.empty?
            baseResult = result
            baseResultStr = result.join("\n")
            puts "\nconvert input #{originalLines} lines to #{result.size} lines in the first case\n"
            passed += 1
          else
            puts "\nconvert input #{originalLines} lines to #{result.size} lines\n"
            sameResult = (baseResultStr == result.join("\n"))
            message = sameResult ? "same as expected" : "different from expected"
            puts message
            passed += 1 if sameResult
            failed += 1 unless sameResult
          end
        end
      end
    end

    puts "====================\n"
    puts "passed = #{passed}, failed = #{failed}, error = #{error}\n\n"
  end

  def formatResult(str)
    allExprMap = {}
    originalLines = str.lines.size

    str.lines.each do |line|
      md = line.chomp.match(/^(\d+)\s*:(.*)$/)
      next unless md

      # value : exprA == exprB == exprC と、 value : exprD == exprE を、
      # value : exprA == exprB == exprC == exprD == exprE にまとめる
      subExprSet = md[2].split("==").map(&:strip)
      key = md[1] + " : "
      allExprMap[key] = [] unless allExprMap.key?(key)
      allExprMap[key].concat(subExprSet)
    end

    allExprSet = []
    allExprMap.each { |key, value| allExprSet << (key + value.sort.uniq.join(" == ")) }
    return originalLines, allExprSet.sort_by(&:to_i)
  end
end

class CommandSet
  def initialize
    passed = 0
    failed = 0
    error = 0

    COMMAND_SET.each do |commands|
      puts "--------------------\n"

      commands.each_with_index do |command, i|
        print "#{command} : "
        stdoutstr = ""
        stderrstr = ""
        status = 1

        startTime = Time.now
        begin
          stdoutstr, stderrstr, status = Open3.capture3(command)
        rescue
        ensure
          elapsedTime = Time.now - startTime
          if (status != 0)
            print "Error\n"
            error += 1
            break
          elsif i == (commands.size - 1)
            print "#{elapsedTime} sec\n"
            result, message = Solution.new(stdoutstr).compare
            puts "result : " + message
            passed += 1 if result
            failed += 1 unless result
          end
        end
      end
    end

    puts "====================\n"
    puts "passed = #{passed}, failed = #{failed}, error = #{error}\n\n"
  end
end

class CommandHttp
  def initialize
    passed = 0
    failed = 0
    error = 0

    puts "--------------------\n"
    URL_SET.each do |url|
      print "#{url}\n"
      str = ""
      begin
        doc = Nokogiri::HTML(open(url))
        str = doc.xpath('//body/p').map(&:inner_text).join("\n")
      rescue
      ensure
        if (str == "")
          print "Error in connection to #{url}\n"
          error += 1
        else
          result, message = Solution.new(str).compare
          puts "result : " + message
          passed += 1 if result
          failed += 1 unless result
        end
      end
    end

    puts "====================\n"
    puts "passed = #{passed}, failed = #{failed}, error = #{error}\n\n"
  end
end

CommandHttp.new
LargeSet.new(LARGE_TEST_CASE, LARGE_COMMAND_SET)
CommandSet.new
LargeSet.new(VERY_LARGE_TEST_CASE, VERY_LARGE_COMMAND_SET)
exit(0)
