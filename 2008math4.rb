#!/usr/bin/ruby
# coding: utf-8
#
# 出題元
# 麻布中学校 2008年 入試問題 算数 問4 解法

class ExprSet
  attr_reader :exprSet

  def initialize(minNum, maxNum)
    @exprSet = ((minNum+1)..maxNum).inject([minNum]) { |xs, i| xs.product(["+", "*"]).product([i]) }.map(&:join)
  end

  def printSums
    strSet = @exprSet.map{ |expr| "#{eval(expr)} = #{expr}"}
    width = strSet.map(&:length).max
    puts strSet.map { |str| str.rjust(width, " ") }.sort
  end

  def printMatchedSums(other)
    puts @exprSet.product(other.exprSet).map { |x| x.join(" == ") }.select { |x| eval x }
  end
end

# 問4-1
ExprSet.new(1,4).printSums
# 問4-2
ExprSet.new(1,5).printMatchedSums(ExprSet.new(2,6))

0