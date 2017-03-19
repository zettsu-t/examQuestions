#!/usr/bin/ruby
# coding: utf-8
#
# 出題元
# 麻布中学校 2008年 入試問題 算数 問4 解法

class ExprSetFast
  attr_reader :exprMap

  def initialize(minNum, maxNum)
    @exprMap = {}
    exprSet = ((minNum+1)..maxNum).inject([minNum]) do |xs, i|
      xs.product(["+", "*"], [i])
    end.map(&:join)

    exprSet.each do |expr|
      key = eval(expr)
      @exprMap[key] = [] unless @exprMap.key?(key)
      @exprMap[key] << expr
    end
  end

  def printSums
    @exprMap.keys.sort.each { |key| @exprMap[key].each { |expr| puts "#{key} = #{expr}" }}
  end

  def printMatchedSums(printValue, other)
    other.exprMap.keys.sort.each do |key|
      next unless @exprMap.key?(key)
      str = printValue ? (key.to_s + " : ") : ""
      str += (@exprMap[key] + other.exprMap[key]).join(" == ")
      puts str
    end
  end
end

if (ARGV.size >= 4)
  v = ARGV.map(&:to_i)
  ExprSetFast.new(v[0],v[1]).printMatchedSums(true, ExprSetFast.new(v[2],v[3]))
else
  # 問4-1
  ExprSetFast.new(1,4).printSums
  # 問4-2
  ExprSetFast.new(1,5).printMatchedSums(false, ExprSetFast.new(2,6))
end

exit(0)
