#! /usr/bin/ruby
# coding: utf-8
# 2018年の麻布中学校の入試問題(算数 問4)の解答例です。
# 問題は以下のサイトにあります。
# https://www.inter-edu.com/nyushi/azabu/

require 'open3'
require 'test/unit'

class Test2018Math < Test::Unit::TestCase
  data(
    'ruby' => "ruby 2018math.rb",
    'bash' => "bash 2018math.sh")
  def test_scripts(data)
    expected="[\"1+4*5==6+7+8\", \"1*4+5+6==7+8\"]\n[\"2*3+5*7==11+13+17\", \"2*3*5*7+11==13*17\"]\n"
    stdoutstr, stderrstr, status = Open3.capture3(data)
    assert_true(status.success?)
    assert_equal(expected, stdoutstr)
  end
end
