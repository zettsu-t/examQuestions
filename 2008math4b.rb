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

  def printMatchedSums(other)
    other.exprMap.keys.sort.each do |key|
      next unless @exprMap.key?(key)
      puts (@exprMap[key] + other.exprMap[key]).join(" == ")
    end
  end
end

if (ARGV.size > 0)
  ExprSetFast.new(1,10).printMatchedSums(ExprSetFast.new(2,11))
else
  # 問4-1
  ExprSetFast.new(1,4).printSums
  # 問4-2
  ExprSetFast.new(1,5).printMatchedSums(ExprSetFast.new(2,6))
end

0
