#!/usr/bin/ruby
# coding: utf-8
#
# 麻布中学校 2008年 入試問題 算数 問4 を解いてテストする

require 'open3'

# 問4の解
SOLUTION_SET = [["9=1*2+3+4", "10=1+2+3+4", "10=1*2*3+4", "11=1+2*3+4",
                 "14=1*2+3*4", "15=1+2+3*4", "24=1*2*3*4", "25=1+2*3*4",
                 "1+2+3*4+5==2+3+4+5+6", "1*2+3+4*5==2+3*4+5+6"],
                ["9=1*2+3+4", "10=1*2*3+4", "10=1+2+3+4", "11=1+2*3+4",
                 "14=1*2+3*4", "15=1+2+3*4", "24=1*2*3*4", "25=1+2*3*4",
                 "1+2+3*4+5==2+3+4+5+6", "1*2+3+4*5==2+3*4+5+6"]]

# Clojure(clojure-1.8.0.jar) は C:\bin\clojure\ に、
# clojure.math.combinatorics は C:\bin\clojure\package にあるという前提
COMMAND_SET = [["ruby 2008math4.rb"],
               ["ruby 2008math4a.rb"],
               ["node 2008math4.js"],
               ["javac 2008math4.java", "java -cp . Exam2008Q4"],
               ["python3 2008math4.py"],
               ["groovy 2008math4.groovy"],
               ["scala 2008math4.scala"], #!!
               ["bash 2008math4.sh"],
               ["make -f 2008math4.mk"],
               ["./2008math4"],
               ["./2008math4a"],
               ["./2008math4hs"],
               ['java -cp "C:\\bin\\clojure\\package;C:\\bin\\clojure\\clojure-1.8.0.jar" clojure.main 2008math4.clj'],
               ["ocaml 2008math4.ml"]]

class Solution
  def initialize(solution)
    @orignal = solution
    @solution = canonicalize(parse(solution))
  end

  def compare
    result = SOLUTION_SET.any?{ |s| @solution == s }
    message = result ? "Same as expected" : "Diffrent from expected"
    [result, message]
  end

  def parse(arg)
    str = arg.chomp
    return [] if str.empty?

    [:parseClojureLog, :parseHaskellLog, :parseRubyLog, :parseScalaLog].each do |f|
      strSet = send(f, str)
      return strSet if strSet
    end

    str.lines.reject{ |s| s.include?("make") || !s.match(/^\s*$/).nil? }
  end

  def parseClojureLog(str)
    return if str.length < 3 || str[0] != "[" || str[-1] != ")"

    strSet = str.lines.map do |line|
      if (line.count("[") > 1)
        line.scan(/\s+\(([^)]+?)\)/).join("==")
      else
        md = line.match(/(\d+)\s*\(([^)]+)\)/)
        md.nil? ? "" : (md[1] + "=" + md[2])
      end
    end
  end

  def parseHaskellLog(str)
    return if str.length < 4 || str[0..1] != "[(" || str[-2..-1] != ")]"
    lines = str.split(/\n/)
    return if lines.size != 2
    strSet =  lines[0].scan(/\(([^)]+?)\)/).flatten.map { |str| str.tr('"','').tr(",", "=") }
    strSet += lines[1].scan(/\(([^)]+?)\)/).flatten.map { |str| str.tr('"','').gsub(/,/, "==") }
    strSet
  end

  def parseRubyLog(str)
    return if str.length < 2 || str[0] != "[" || str[-1] != "]"
    str.split(/,|\n/)
  end

  def parseScalaLog(str)
    return if str.length < 2 || str[0] != "(" || str[-1] != ")"

    strSet = str.lines.map do |line|
      if line.include?("List")
        md = line.match(/List\(([^(]+)\)/)
        md.nil? ? "" : md[1]
      else
        md = line.match(/(\d+),([^(]+)\)/)
        md.nil? ? "" : (md[1] + "=" + md[2])
      end
    end

    strSet
  end

  def canonicalize(strSet)
    return [] if strSet.nil?
    lines = strSet.map{ |str| str.chomp.tr('" ()[]','') }
    solution1 = lines.reject { |line| line.include?("==") }.sort_by(&:to_i)
    solution2 = lines.select { |line| line.include?("==") }
    solution1 + solution2
  end
end

class CommandSet
  def initialize
    passed = 0
    failed = 0
    error = 0

    COMMAND_SET.each do |commands|
      puts "====================\n"
      commands.each_with_index do |command, i|
        stdoutstr, stderrstr, status = Open3.capture3(command)
        if (status != 0)
          warn "> Error in #{command}\n"
          error += 1
          next
        elsif i == (commands.size - 1)
          puts "> #{command}\n#{stdoutstr}"
          result, message = Solution.new(stdoutstr).compare
          puts "Result : " + message
          passed += 1 if result
          failed += 1 unless result
        end
      end
    end

    puts "passed = #{passed}, failed = #{failed}, error = #{error}\n"
  end
end

CommandSet.new
0
